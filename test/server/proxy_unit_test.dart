// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../server/lib/src/auth_service.dart';
import '../../server/lib/src/client_auth.dart';
import '../../server/lib/src/food_parsers.dart';
import '../../server/lib/src/json_helpers.dart';
import '../../server/lib/src/proxy_env_loader.dart';
import '../../server/lib/src/proxy_exceptions.dart';
import '../../server/lib/src/rate_limiter.dart';
import '../../server/lib/src/server_database.dart';
import '../../server/lib/src/upstream_client.dart';

void main() {
  group('proxy authentication', () {
    test('skips authorization when no client token is configured', () {
      expect(validateClientAuthorizationHeader(null, ''), isNull);
    });

    test('requires a bearer token when client token is configured', () {
      final error = validateClientAuthorizationHeader(null, 'client-token');

      expect(error, isA<ClientException>());
      expect(error?.statusCode, HttpStatus.unauthorized);
    });

    test('rejects invalid bearer tokens', () {
      final error = validateClientAuthorizationHeader(
        'Bearer wrong-token',
        'client-token',
      );

      expect(error, isA<ClientException>());
      expect(error?.statusCode, HttpStatus.forbidden);
    });

    test('accepts valid bearer tokens case-insensitively', () {
      expect(
        validateClientAuthorizationHeader(
          'bearer client-token',
          'client-token',
        ),
        isNull,
      );
    });

    test('extracts and trims bearer token values', () {
      expect(readBearerToken('  Bearer   client-token  '), 'client-token');
      expect(readBearerToken('Basic client-token'), isNull);
    });
  });

  group('RateLimiter', () {
    test('allows requests until the configured minute bucket is exhausted', () {
      var now = DateTime(2026, 1, 1, 12);
      final limiter = RateLimiter(2, clock: () => now);

      expect(limiter.allow('127.0.0.1'), isTrue);
      expect(limiter.allow('127.0.0.1'), isTrue);
      expect(limiter.allow('127.0.0.1'), isFalse);

      now = now.add(const Duration(minutes: 1));

      expect(limiter.allow('127.0.0.1'), isTrue);
    });

    test('treats non-positive limits as unlimited', () {
      final limiter = RateLimiter(0);

      expect(
        List.generate(100, (_) => limiter.allow('127.0.0.1')),
        everyElement(isTrue),
      );
    });
  });

  group('server auth infrastructure', () {
    test('hashes and verifies passwords with PBKDF2', () {
      final hasher = PasswordHasher(iterations: 2);
      final encoded = hasher.hash('correct-password');

      expect(encoded, startsWith(r'pbkdf2_sha256$2$'));
      expect(hasher.verify('correct-password', encoded), isTrue);
      expect(hasher.verify('wrong-password', encoded), isFalse);
    });

    test('creates and verifies signed access tokens', () {
      final now = DateTime.utc(2026, 1, 1);
      final user = StoredUser(
        id: 'user-1',
        email: 'user@example.com',
        passwordHash: 'hash',
        createdAt: now,
      );
      final service = AccessTokenService(
        secret: '12345678901234567890123456789012',
        ttl: const Duration(minutes: 30),
        clock: () => now,
      );

      final token = service.create(user);
      final claims = service.verify(token);

      expect(claims?.subject, 'user-1');
      expect(claims?.expiresAt, now.add(const Duration(minutes: 30)));
      expect(service.verify('$token.tampered'), isNull);
    });

    test('persists users and meal records to the server database', () async {
      final directory = Directory.systemTemp.createTempSync(
        'sikdanscan_db_unit_test_',
      );
      try {
        final path = '${directory.path}/db.json';
        final database = FileServerDatabase(path);
        await database.open();

        final user = await database.createUser(
          email: 'USER@example.com',
          passwordHash: 'hash',
          displayName: 'Tester',
        );
        await database.addMealRecord(user.id, {'name': '김밥', 'kcal': 420});

        final reopened = FileServerDatabase(path);
        await reopened.open();

        expect(
          (await reopened.findUserByEmail('user@example.com'))?.id,
          user.id,
        );
        expect(await reopened.listMealRecords(user.id), hasLength(1));
      } finally {
        directory.deleteSync(recursive: true);
      }
    });
  });

  group('proxy environment loader', () {
    test('parses dotenv files defensively', () {
      final values = parseProxyDotenv('''
# comment
OPENAI_API_KEY=openai-key
export FOOD_API_KEY="food-key"
INVALID-KEY=ignored
PORT=8080
EMPTY=
''');

      expect(values['OPENAI_API_KEY'], 'openai-key');
      expect(values['FOOD_API_KEY'], 'food-key');
      expect(values['PORT'], '8080');
      expect(values['EMPTY'], '');
      expect(values.containsKey('INVALID-KEY'), isFalse);
    });

    test('loads .env.proxy before .env without overriding process values', () {
      final directory = Directory.systemTemp.createTempSync(
        'sikdanscan_proxy_env_test_',
      );
      try {
        File('${directory.path}/.env').writeAsStringSync('FOOD_API_KEY=env\n');
        File(
          '${directory.path}/.env.proxy',
        ).writeAsStringSync('OPENAI_API_KEY=proxy\nFOOD_API_KEY=proxy\n');

        final values = loadProxyEnvironment({
          'OPENAI_API_KEY': 'process',
        }, directory: directory);

        expect(values['OPENAI_API_KEY'], 'process');
        expect(values['FOOD_API_KEY'], 'proxy');
      } finally {
        directory.deleteSync(recursive: true);
      }
    });
  });

  group('upstream error handling', () {
    test('extracts OpenAI error messages from JSON payloads', () {
      final message = readUpstreamErrorMessage('''
{
  "error": {
    "message": "Invalid image.",
    "code": "invalid_image",
    "type": "invalid_request_error"
  }
}
''');

      expect(message, contains('Invalid image.'));
      expect(message, contains('code=invalid_image'));
      expect(message, contains('type=invalid_request_error'));
    });

    test('ignores malformed upstream error payloads', () {
      expect(readUpstreamErrorMessage('not json'), isNull);
    });
  });

  group('food parsers', () {
    test('normalizes public food API payloads', () {
      final items = parsePublicFoodItems({
        'header': {'resultCode': '00'},
        'body': {
          'items': {
            'item': [
              {
                'FOOD_NM_KR': '  닭가슴살구이  ',
                'AMT_NUM1': '165 kcal',
                'AMT_NUM6': '0',
                'AMT_NUM3': '31',
                'AMT_NUM4': '3.6',
                'SERVING_SIZE': '100g',
              },
              {'FOOD_NM_KR': '열량 없음', 'AMT_NUM1': '0'},
            ],
          },
        },
      });

      expect(items, hasLength(1));
      expect(items.single, {
        'name': '닭가슴살구이',
        'calories': 165,
        'carbs': 0.0,
        'protein': 31.0,
        'fat': 3.6,
        'servingSize': '100g',
        'source': 'publicApi',
        'isAiGenerated': false,
      });
    });

    test('normalizes AI food analysis payloads embedded in fenced JSON', () {
      final items = parseAiFoodItems('''
```json
[
  {
    "name": "현미밥",
    "calories": "310 kcal",
    "carbs": "68g",
    "protein": 6,
    "fat": 2,
    "servingSize": "1공기"
  },
  {
    "name": "",
    "calories": 120
  }
]
```
''');

      expect(items, hasLength(1));
      expect(items.single, {
        'name': '현미밥',
        'calories': 310,
        'carbs': 68.0,
        'protein': 6.0,
        'fat': 2.0,
        'servingSize': '1공기',
        'source': 'aiAnalysis',
        'isAiGenerated': true,
      });
    });

    test('returns an empty list for malformed AI food content', () {
      expect(parseAiFoodItems('not json'), isEmpty);
    });

    test('normalizes AI food image recognition payloads', () {
      final result = parseAiFoodRecognition('''
```json
{
  "summary": "김치찌개와 현미밥",
  "confidence": "0.84",
  "needsReview": false,
  "items": [
    {
      "name": "김치찌개",
      "calories": "430 kcal",
      "carbs": "18.5g",
      "protein": "24g",
      "fat": "28g",
      "servingSize": "1그릇",
      "confidence": "0.82"
    },
    {
      "name": "",
      "calories": 10
    }
  ]
}
```
''');

      expect(result['summary'], '김치찌개와 현미밥');
      expect(result['confidence'], 0.84);
      expect(result['needsReview'], isFalse);
      expect(result['items'], hasLength(1));
      expect((result['items'] as List).single, {
        'name': '김치찌개',
        'calories': 430,
        'carbs': 18.5,
        'protein': 24.0,
        'fat': 28.0,
        'servingSize': '1그릇',
        'confidence': 0.82,
      });
    });

    test('marks low-confidence food image recognition as review required', () {
      final result = parseAiFoodRecognition('''
{
  "summary": "흐릿한 접시",
  "confidence": 0.4,
  "needsReview": false,
  "items": []
}
''');

      expect(result['needsReview'], isTrue);
      expect(result['items'], isEmpty);
    });
  });

  group('json helpers', () {
    test('requires request bodies to decode to JSON objects', () {
      expect(
        () => decodeJsonObject('[1, 2, 3]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('reads numeric strings defensively', () {
      expect(readNumeric('1,234.5 kcal'), 1234.5);
      expect(readNumeric('-12'), 0);
      expect(readNumeric('unknown'), 0);
    });
  });
}
