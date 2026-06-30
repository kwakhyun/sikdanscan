import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'client_auth.dart';
import 'cors.dart';
import 'food_parsers.dart';
import 'http_response.dart';
import 'json_helpers.dart';
import 'observability.dart';
import 'prompts.dart';
import 'proxy_config.dart';
import 'proxy_exceptions.dart';
import 'request_body.dart';
import 'server_database.dart';
import 'upstream_client.dart';

Future<void> handleRequest(HttpRequest request, ProxyConfig config) async {
  final requestId = ensureRequestId(request);
  final stopwatch = Stopwatch()..start();
  final remoteAddress =
      request.connectionInfo?.remoteAddress.address ?? 'unknown';

  try {
    await _handleRequestInternal(request, config);
  } finally {
    stopwatch.stop();
    final statusCode = request.response.statusCode;
    config.metrics.record(
      method: request.method,
      path: request.uri.path,
      statusCode: statusCode,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    config.logger.request(
      requestId: requestId,
      method: request.method,
      path: request.uri.path,
      statusCode: statusCode,
      durationMs: stopwatch.elapsedMilliseconds,
      remoteAddress: remoteAddress,
    );
  }
}

Future<void> _handleRequestInternal(
  HttpRequest request,
  ProxyConfig config,
) async {
  if (!applyCorsHeaders(request, config)) {
    await sendError(request, HttpStatus.forbidden, 'Origin is not allowed.');
    return;
  }

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  final clientIp = request.connectionInfo?.remoteAddress.address ?? 'unknown';
  if (!config.rateLimiter.allow(clientIp)) {
    await sendError(
      request,
      HttpStatus.tooManyRequests,
      'Too many requests. Try again later.',
    );
    return;
  }

  try {
    final path = request.uri.path;
    if (request.method == 'GET' && path == '/health') {
      await sendJson(request, {'status': 'ok'});
      return;
    }

    if (request.method == 'GET' && path == '/ready') {
      await _handleReady(request, config);
      return;
    }

    if (request.method == 'GET' && path == '/metrics') {
      if (!await _requireProxyClient(request, config)) return;
      await sendText(
        request,
        config.metrics.toPrometheus(),
        contentType: ContentType('text', 'plain', charset: 'utf-8'),
      );
      return;
    }

    if (request.method == 'POST' && path == '/v1/auth/register') {
      if (!await _requireProxyClient(request, config)) return;
      await _handleRegister(request, config);
      return;
    }

    if (request.method == 'POST' && path == '/v1/auth/login') {
      if (!await _requireProxyClient(request, config)) return;
      await _handleLogin(request, config);
      return;
    }

    if (path == '/v1/me' || path == '/v1/me/meals') {
      await _handleUserScopedRequest(request, config);
      return;
    }

    final authError = validateClientAuthorization(request, config);
    if (authError != null) {
      await sendError(request, authError.statusCode, authError.message);
      return;
    }

    if (request.method == 'POST' && path == '/v1/chat') {
      await _handleChat(request, config);
      return;
    }

    if (request.method == 'GET' && path == '/v1/foods/public') {
      await _handlePublicFoodSearch(request, config);
      return;
    }

    if (request.method == 'POST' && path == '/v1/foods/analyze') {
      await _handleFoodAnalysis(request, config);
      return;
    }

    if (request.method == 'POST' && path == '/v1/foods/recognize') {
      await _handleFoodImageRecognition(request, config);
      return;
    }

    await sendError(request, HttpStatus.notFound, 'Not found.');
  } on ClientException catch (error) {
    await sendError(request, error.statusCode, error.message);
  } on UpstreamException catch (error) {
    await sendError(
      request,
      _proxyStatusForUpstream(error.statusCode),
      _upstreamClientMessage(error),
    );
  } on FormatException {
    await sendError(request, HttpStatus.badRequest, 'Malformed JSON body.');
  } catch (_) {
    await sendError(
      request,
      HttpStatus.internalServerError,
      'Internal server error.',
    );
  }
}

Future<bool> _requireProxyClient(
  HttpRequest request,
  ProxyConfig config,
) async {
  final authError = validateClientAuthorization(request, config);
  if (authError != null) {
    await sendError(request, authError.statusCode, authError.message);
    return false;
  }
  return true;
}

Future<void> _handleReady(HttpRequest request, ProxyConfig config) async {
  await config.database.open();
  await sendJson(request, {
    'status': config.database.isReady ? 'ok' : 'degraded',
    'database': {'ready': config.database.isReady, 'type': 'file'},
    'auth': {'configured': config.authService.isConfigured},
    'upstreams': {
      'openAiConfigured': config.openAiApiKey.isNotEmpty,
      'foodApiConfigured': config.foodApiKey.isNotEmpty,
    },
  });
}

Future<void> _handleRegister(HttpRequest request, ProxyConfig config) async {
  _ensureAuthConfigured(config);
  final body = await readJsonObject(request);
  final email = _readRequiredEmail(body);
  final password = _readRequiredPassword(body);
  final displayName = readString(body['displayName']) ?? '';

  try {
    final session = await config.authService.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    await sendJson(request, session.toJson(), statusCode: HttpStatus.created);
  } on DuplicateUserException {
    throw const ClientException(HttpStatus.conflict, 'User already exists.');
  }
}

Future<void> _handleLogin(HttpRequest request, ProxyConfig config) async {
  _ensureAuthConfigured(config);
  final body = await readJsonObject(request);
  final email = _readRequiredEmail(body);
  final password = _readRequiredPassword(body);
  final session = await config.authService.login(
    email: email,
    password: password,
  );

  if (session == null) {
    throw const ClientException(
      HttpStatus.unauthorized,
      'Invalid email or password.',
    );
  }

  await sendJson(request, session.toJson());
}

Future<void> _handleUserScopedRequest(
  HttpRequest request,
  ProxyConfig config,
) async {
  final user = await _requireUser(request, config);
  final path = request.uri.path;

  if (request.method == 'GET' && path == '/v1/me') {
    await sendJson(request, {'user': user.toPublicJson()});
    return;
  }

  if (request.method == 'GET' && path == '/v1/me/meals') {
    final records = await config.database.listMealRecords(user.id);
    await sendJson(request, {'items': records});
    return;
  }

  if (request.method == 'POST' && path == '/v1/me/meals') {
    final body = await readJsonObject(request);
    final record = asStringMap(body['record']);
    if (record == null) {
      throw const ClientException(
        HttpStatus.badRequest,
        'record object is required.',
      );
    }
    final stored = await config.database.addMealRecord(user.id, record);
    await sendJson(request, {'item': stored}, statusCode: HttpStatus.created);
    return;
  }

  await sendError(request, HttpStatus.methodNotAllowed, 'Method not allowed.');
}

Future<StoredUser> _requireUser(HttpRequest request, ProxyConfig config) async {
  _ensureAuthConfigured(config);
  final authorization = request.headers.value(HttpHeaders.authorizationHeader);
  final token = authorization == null ? null : readBearerToken(authorization);
  if (token == null) {
    throw const ClientException(
      HttpStatus.unauthorized,
      'User access token is required.',
    );
  }

  final user = await config.authService.userForToken(token);
  if (user == null) {
    throw const ClientException(
      HttpStatus.unauthorized,
      'User access token is invalid or expired.',
    );
  }

  return user;
}

void _ensureAuthConfigured(ProxyConfig config) {
  if (!config.authService.isConfigured) {
    throw const ClientException(
      HttpStatus.serviceUnavailable,
      'AUTH_TOKEN_SECRET must be configured on the proxy.',
    );
  }
}

String _readRequiredEmail(Map<String, dynamic> body) {
  final email = readString(body['email']);
  if (email == null || !email.contains('@')) {
    throw const ClientException(
      HttpStatus.badRequest,
      'A valid email is required.',
    );
  }
  return email;
}

String _readRequiredPassword(Map<String, dynamic> body) {
  final password = readString(body['password']);
  if (password == null || password.length < 8) {
    throw const ClientException(
      HttpStatus.badRequest,
      'Password must be at least 8 characters.',
    );
  }
  return password;
}

Future<void> _handleFoodImageRecognition(
  HttpRequest request,
  ProxyConfig config,
) async {
  if (config.openAiApiKey.isEmpty) {
    throw const ClientException(
      HttpStatus.serviceUnavailable,
      'OPENAI_API_KEY is not configured on the proxy.',
    );
  }

  final body = await readJsonObject(
    request,
    maxBytes: maxImageRecognitionBodyBytes,
  );
  final locale = _normalizeLocale(readString(body['locale']));
  final rawImage = readString(body['imageBase64']);
  if (rawImage == null) {
    throw const ClientException(
      HttpStatus.badRequest,
      'imageBase64 is required.',
    );
  }

  final mimeType = _validateImageMimeType(readString(body['mimeType']));
  final imageBase64 = _normalizeBase64Image(rawImage);
  final imageBytes = _decodeImageBytes(imageBase64);
  if (imageBytes.length > 4 * 1024 * 1024) {
    throw const ClientException(
      HttpStatus.requestEntityTooLarge,
      'Image is too large.',
    );
  }

  final response = await postOpenAiChat(config, {
    'model': config.openAiModel,
    'messages': [
      {'role': 'system', 'content': buildFoodImageRecognitionPrompt(locale)},
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': locale == 'en'
                ? 'Analyze this meal photo and return food and nutrition information as JSON so it can be saved in SikdanScan.'
                : '이 식사 사진을 분석해 식단스캔 기록으로 저장할 수 있는 음식과 영양 정보를 JSON으로 반환하세요.',
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:$mimeType;base64,$imageBase64',
              'detail': 'low',
            },
          },
        ],
      },
    ],
    'max_completion_tokens': 900,
  });

  final content = extractOpenAiContent(response);
  if (content == null || content.isEmpty) {
    await sendJson(request, {
      'summary': '',
      'confidence': 0.0,
      'needsReview': true,
      'warning': '음식을 안정적으로 인식하지 못했습니다.',
      'items': const [],
    });
    return;
  }

  await sendJson(request, parseAiFoodRecognition(content));
}

int _proxyStatusForUpstream(int upstreamStatusCode) {
  if (upstreamStatusCode == HttpStatus.tooManyRequests) {
    return HttpStatus.tooManyRequests;
  }
  if (upstreamStatusCode == HttpStatus.gatewayTimeout ||
      upstreamStatusCode == HttpStatus.requestTimeout) {
    return HttpStatus.gatewayTimeout;
  }
  if (upstreamStatusCode >= 400 && upstreamStatusCode < 500) {
    return HttpStatus.unprocessableEntity;
  }
  return HttpStatus.badGateway;
}

String _upstreamClientMessage(UpstreamException error) {
  final upstreamMessage = error.message;
  if (error.statusCode == HttpStatus.tooManyRequests) {
    return 'AI 분석 요청이 많습니다. 잠시 후 다시 시도해주세요.';
  }
  if (error.statusCode == HttpStatus.unauthorized ||
      error.statusCode == HttpStatus.forbidden) {
    return 'OpenAI upstream 인증 또는 권한을 확인해주세요.';
  }
  if (error.statusCode >= 400 && error.statusCode < 500) {
    if (upstreamMessage != null && upstreamMessage.isNotEmpty) {
      return 'AI 이미지 분석 요청을 처리할 수 없습니다. $upstreamMessage';
    }
    return 'AI 이미지 분석 요청을 처리할 수 없습니다. 이미지 형식 또는 모델 설정을 확인해주세요.';
  }
  if (error.statusCode == HttpStatus.gatewayTimeout ||
      error.statusCode == HttpStatus.requestTimeout) {
    return 'AI 분석 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
  }
  return 'AI 분석 서버가 정상 응답하지 않습니다. 잠시 후 다시 시도해주세요.';
}

Future<void> _handleChat(HttpRequest request, ProxyConfig config) async {
  if (config.openAiApiKey.isEmpty) {
    throw const ClientException(
      HttpStatus.serviceUnavailable,
      'OPENAI_API_KEY is not configured on the proxy.',
    );
  }

  final body = await readJsonObject(request);
  final message = readString(body['message']);
  if (message == null) {
    throw const ClientException(HttpStatus.badRequest, 'message is required.');
  }

  final context = asStringMap(body['context']);
  final locale = _normalizeLocale(readString(body['locale']));
  final response = await postOpenAiChat(config, {
    'model': config.openAiModel,
    'messages': [
      {
        'role': 'system',
        'content': buildAiCoachPrompt(context, locale: locale),
      },
      {'role': 'user', 'content': message},
    ],
    'max_completion_tokens': 500,
  });

  final content = extractOpenAiContent(response);
  if (content == null || content.isEmpty) {
    throw const UpstreamException(HttpStatus.badGateway);
  }

  await sendJson(request, {'content': content});
}

String _validateImageMimeType(String? mimeType) {
  final normalized = mimeType?.toLowerCase();
  if (normalized == null || normalized.isEmpty) return 'image/jpeg';

  if (normalized == 'image/jpeg' ||
      normalized == 'image/png' ||
      normalized == 'image/webp') {
    return normalized;
  }

  throw const ClientException(
    HttpStatus.badRequest,
    'Unsupported image mime type.',
  );
}

String _normalizeBase64Image(String rawImage) {
  final commaIndex = rawImage.indexOf(',');
  return commaIndex == -1 ? rawImage : rawImage.substring(commaIndex + 1);
}

List<int> _decodeImageBytes(String imageBase64) {
  try {
    return base64Decode(imageBase64);
  } on FormatException {
    throw const ClientException(
      HttpStatus.badRequest,
      'imageBase64 must be valid base64.',
    );
  }
}

Future<void> _handlePublicFoodSearch(
  HttpRequest request,
  ProxyConfig config,
) async {
  if (config.foodApiKey.isEmpty) {
    throw const ClientException(
      HttpStatus.serviceUnavailable,
      'FOOD_API_KEY is not configured on the proxy.',
    );
  }

  final query = readString(request.uri.queryParameters['query']);
  if (query == null) {
    throw const ClientException(HttpStatus.badRequest, 'query is required.');
  }

  final data = await getPublicFoodPayload(config, query);
  final items = parsePublicFoodItems(data);
  await sendJson(request, {'items': items});
}

Future<void> _handleFoodAnalysis(
  HttpRequest request,
  ProxyConfig config,
) async {
  if (config.openAiApiKey.isEmpty) {
    throw const ClientException(
      HttpStatus.serviceUnavailable,
      'OPENAI_API_KEY is not configured on the proxy.',
    );
  }

  final body = await readJsonObject(request);
  final query = readString(body['query']);
  if (query == null) {
    throw const ClientException(HttpStatus.badRequest, 'query is required.');
  }

  final locale = _normalizeLocale(readString(body['locale']));
  final response = await postOpenAiChat(config, {
    'model': config.openAiModel,
    'messages': [
      {'role': 'system', 'content': buildFoodAnalysisPrompt(locale)},
      {'role': 'user', 'content': query},
    ],
    'max_completion_tokens': 500,
  });

  final content = extractOpenAiContent(response);
  if (content == null || content.isEmpty) {
    await sendJson(request, {'items': []});
    return;
  }

  await sendJson(request, {'items': parseAiFoodItems(content)});
}

String _normalizeLocale(String? locale) {
  return locale?.toLowerCase().startsWith('en') == true ? 'en' : 'ko';
}

Future<void> serveRequests(HttpServer server, ProxyConfig config) async {
  try {
    await for (final request in server) {
      unawaited(handleRequest(request, config));
    }
  } finally {
    config.close();
  }
}
