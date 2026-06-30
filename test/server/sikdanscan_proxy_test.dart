import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SikdanScan proxy server', () {
    test(
      'health endpoint is public even when client token is configured',
      () async {
        final proxy = await _startProxy(clientToken: 'client-token');
        addTearDown(proxy.stop);

        final response = await _request(proxy, 'GET', '/health');

        expect(response.statusCode, HttpStatus.ok);
        expect(response.jsonBody?['status'], 'ok');
        expect(response.headers.value('x-request-id'), isNotEmpty);
      },
    );

    test('ready endpoint reports database and auth readiness', () async {
      final proxy = await _startProxy(
        authTokenSecret: '12345678901234567890123456789012',
      );
      addTearDown(proxy.stop);

      final response = await _request(proxy, 'GET', '/ready');

      expect(response.statusCode, HttpStatus.ok);
      expect(response.jsonBody?['status'], 'ok');
      expect(response.jsonBody?['database'], containsPair('ready', true));
      expect(response.jsonBody?['auth'], containsPair('configured', true));
    });

    test(
      'supports register, login, current user, and meal persistence',
      () async {
        final proxy = await _startProxy(
          clientToken: 'client-token',
          authTokenSecret: '12345678901234567890123456789012',
        );
        addTearDown(proxy.stop);

        final register = await _request(
          proxy,
          'POST',
          '/v1/auth/register',
          headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
          body: {
            'email': 'USER@example.com',
            'password': 'password-1234',
            'displayName': 'Tester',
          },
        );
        expect(register.statusCode, HttpStatus.created);
        expect(register.jsonBody?['accessToken'], isA<String>());

        final duplicate = await _request(
          proxy,
          'POST',
          '/v1/auth/register',
          headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
          body: {'email': 'user@example.com', 'password': 'password-1234'},
        );
        expect(duplicate.statusCode, HttpStatus.conflict);

        final login = await _request(
          proxy,
          'POST',
          '/v1/auth/login',
          headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
          body: {'email': 'user@example.com', 'password': 'password-1234'},
        );
        expect(login.statusCode, HttpStatus.ok);
        final accessToken = login.jsonBody?['accessToken'] as String;

        final me = await _request(
          proxy,
          'GET',
          '/v1/me',
          headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
        );
        expect(me.statusCode, HttpStatus.ok);
        expect(me.jsonBody?['user'], containsPair('email', 'user@example.com'));

        final savedMeal = await _request(
          proxy,
          'POST',
          '/v1/me/meals',
          headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
          body: {
            'record': {'name': '치즈버거', 'calories': 520},
          },
        );
        expect(savedMeal.statusCode, HttpStatus.created);

        final meals = await _request(
          proxy,
          'GET',
          '/v1/me/meals',
          headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
        );
        expect(meals.statusCode, HttpStatus.ok);
        expect(meals.jsonBody?['items'], hasLength(1));
      },
    );

    test('exposes metrics behind the proxy client token gate', () async {
      final proxy = await _startProxy(clientToken: 'client-token');
      addTearDown(proxy.stop);

      await _request(proxy, 'GET', '/health');
      final denied = await _request(proxy, 'GET', '/metrics');
      final allowed = await _request(
        proxy,
        'GET',
        '/metrics',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
      );

      expect(denied.statusCode, HttpStatus.unauthorized);
      expect(allowed.statusCode, HttpStatus.ok);
      expect(allowed.body, contains('sikdanscan_proxy_requests_total'));
    });

    test('protected endpoints require a valid bearer token', () async {
      final proxy = await _startProxy(clientToken: 'client-token');
      addTearDown(proxy.stop);

      final missingToken = await _request(
        proxy,
        'POST',
        '/v1/chat',
        body: {'message': 'hello'},
      );
      final wrongToken = await _request(
        proxy,
        'POST',
        '/v1/chat',
        headers: {HttpHeaders.authorizationHeader: 'Bearer wrong-token'},
        body: {'message': 'hello'},
      );
      final validTokenMissingOpenAiKey = await _request(
        proxy,
        'POST',
        '/v1/chat',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
        body: {'message': 'hello'},
      );

      expect(missingToken.statusCode, HttpStatus.unauthorized);
      expect(wrongToken.statusCode, HttpStatus.forbidden);
      expect(
        validTokenMissingOpenAiKey.statusCode,
        HttpStatus.serviceUnavailable,
      );
    });

    test('rejects request bodies larger than the proxy limit', () async {
      final proxy = await _startProxy(
        clientToken: 'client-token',
        openAiApiKey: 'test-openai-key',
      );
      addTearDown(proxy.stop);

      final oversizedMessage = List.filled(33 * 1024, 'x').join();
      final response = await _request(
        proxy,
        'POST',
        '/v1/chat',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
        rawBody: jsonEncode({'message': oversizedMessage}),
      );

      expect(response.statusCode, HttpStatus.requestEntityTooLarge);
    });

    test('returns bad request for malformed JSON bodies', () async {
      final proxy = await _startProxy(
        clientToken: 'client-token',
        openAiApiKey: 'test-openai-key',
      );
      addTearDown(proxy.stop);

      final response = await _request(
        proxy,
        'POST',
        '/v1/chat',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
        rawBody: '{"message":',
      );

      expect(response.statusCode, HttpStatus.badRequest);
      expect(response.jsonBody?['error'], 'Malformed JSON body.');
    });

    test('validates food image recognition payloads before upstream', () async {
      final proxy = await _startProxy(
        clientToken: 'client-token',
        openAiApiKey: 'test-openai-key',
      );
      addTearDown(proxy.stop);

      final unsupportedMimeType = await _request(
        proxy,
        'POST',
        '/v1/foods/recognize',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
        body: {
          'imageBase64': base64Encode([1, 2, 3]),
          'mimeType': 'image/gif',
        },
      );
      final malformedImage = await _request(
        proxy,
        'POST',
        '/v1/foods/recognize',
        headers: {HttpHeaders.authorizationHeader: 'Bearer client-token'},
        body: {'imageBase64': 'not-base64', 'mimeType': 'image/jpeg'},
      );

      expect(unsupportedMimeType.statusCode, HttpStatus.badRequest);
      expect(malformedImage.statusCode, HttpStatus.badRequest);
    });

    test('rejects browser requests from disallowed origins', () async {
      final proxy = await _startProxy(allowedOrigins: 'http://allowed.example');
      addTearDown(proxy.stop);

      final blocked = await _request(
        proxy,
        'GET',
        '/health',
        headers: {'Origin': 'http://blocked.example'},
      );
      final allowed = await _request(
        proxy,
        'GET',
        '/health',
        headers: {'Origin': 'http://allowed.example'},
      );

      expect(blocked.statusCode, HttpStatus.forbidden);
      expect(
        blocked.headers.value(HttpHeaders.accessControlAllowOriginHeader),
        isNull,
      );
      expect(allowed.statusCode, HttpStatus.ok);
      expect(
        allowed.headers.value(HttpHeaders.accessControlAllowOriginHeader),
        'http://allowed.example',
      );
    });

    test('applies the configured per-minute rate limit', () async {
      final proxy = await _startProxy(rateLimitPerMinute: 2);
      addTearDown(proxy.stop);

      final first = await _request(proxy, 'GET', '/health');
      final second = await _request(proxy, 'GET', '/health');
      final third = await _request(proxy, 'GET', '/health');

      expect(first.statusCode, HttpStatus.ok);
      expect(second.statusCode, HttpStatus.ok);
      expect(third.statusCode, HttpStatus.tooManyRequests);
    });
  });
}

Future<_StartedProxy> _startProxy({
  String clientToken = '',
  String openAiApiKey = '',
  String foodApiKey = '',
  String allowedOrigins = '',
  int rateLimitPerMinute = 60,
  String authTokenSecret = '',
  String? databasePath,
}) async {
  final port = await _findFreePort();
  final databaseDirectory = Directory.systemTemp.createTempSync(
    'sikdanscan_proxy_db_test_',
  );
  final effectiveDatabasePath =
      databasePath ?? '${databaseDirectory.path}/db.json';
  final process = await Process.start(
    _dartExecutable,
    ['server/bin/sikdanscan_proxy.dart'],
    workingDirectory: Directory.current.path,
    environment: {
      'PORT': '$port',
      'PROXY_CLIENT_TOKEN': clientToken,
      'OPENAI_API_KEY': openAiApiKey,
      'FOOD_API_KEY': foodApiKey,
      'ALLOWED_ORIGINS': allowedOrigins,
      'PROXY_RATE_LIMIT_PER_MINUTE': '$rateLimitPerMinute',
      'AUTH_TOKEN_SECRET': authTokenSecret,
      'DATABASE_PATH': effectiveDatabasePath,
    },
  );

  final output = StringBuffer();
  final ready = Completer<void>();

  late final StreamSubscription<String> stdoutSub;
  late final StreamSubscription<String> stderrSub;

  stdoutSub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        output.writeln(line);
        if (!ready.isCompleted && line.contains('proxy listening')) {
          ready.complete();
        }
      });

  stderrSub = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen(output.writeln);

  unawaited(
    process.exitCode.then((code) {
      if (!ready.isCompleted) {
        ready.completeError(
          StateError('Proxy exited before becoming ready ($code): $output'),
        );
      }
    }),
  );

  try {
    await ready.future.timeout(const Duration(seconds: 15));
  } catch (error) {
    process.kill();
    await stdoutSub.cancel();
    await stderrSub.cancel();
    throw StateError('Proxy did not become ready: $error\n$output');
  }

  return _StartedProxy(
    process: process,
    port: port,
    stdoutSub: stdoutSub,
    stderrSub: stderrSub,
    databaseDirectory: databaseDirectory,
  );
}

String get _dartExecutable {
  final executable = Platform.resolvedExecutable;
  if (executable.endsWith('/dart') || executable.endsWith(r'\dart.exe')) {
    return executable;
  }
  return 'dart';
}

Future<int> _findFreePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<_HttpResult> _request(
  _StartedProxy proxy,
  String method,
  String path, {
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  String? rawBody,
}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse('http://127.0.0.1:${proxy.port}$path');
    final request = method == 'POST'
        ? await client.postUrl(uri)
        : await client.getUrl(uri);

    headers?.forEach(request.headers.set);
    final encodedBody = rawBody ?? (body == null ? null : jsonEncode(body));
    if (encodedBody != null) {
      final encodedBytes = utf8.encode(encodedBody);
      request.headers.contentType = ContentType.json;
      request.contentLength = encodedBytes.length;
      request.add(encodedBytes);
    }

    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();

    return _HttpResult(
      statusCode: response.statusCode,
      body: responseBody,
      headers: response.headers,
    );
  } finally {
    client.close(force: true);
  }
}

class _StartedProxy {
  _StartedProxy({
    required this.process,
    required this.port,
    required this.stdoutSub,
    required this.stderrSub,
    required this.databaseDirectory,
  });

  final Process process;
  final int port;
  final StreamSubscription<String> stdoutSub;
  final StreamSubscription<String> stderrSub;
  final Directory databaseDirectory;

  Future<void> stop() async {
    process.kill();
    await stdoutSub.cancel();
    await stderrSub.cancel();
    await process.exitCode.timeout(
      const Duration(seconds: 3),
      onTimeout: () => -1,
    );
    if (databaseDirectory.existsSync()) {
      databaseDirectory.deleteSync(recursive: true);
    }
  }
}

class _HttpResult {
  _HttpResult({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  final int statusCode;
  final String body;
  final HttpHeaders headers;

  Map<String, dynamic>? get jsonBody {
    final decoded = jsonDecode(body);
    if (decoded is! Map) return null;
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }
}
