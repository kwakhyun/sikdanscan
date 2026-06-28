import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'client_auth.dart';
import 'cors.dart';
import 'food_parsers.dart';
import 'http_response.dart';
import 'json_helpers.dart';
import 'prompts.dart';
import 'proxy_config.dart';
import 'proxy_exceptions.dart';
import 'request_body.dart';
import 'upstream_client.dart';

Future<void> handleRequest(HttpRequest request, ProxyConfig config) async {
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
