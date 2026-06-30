import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'client_auth.dart';
import 'json_helpers.dart';
import 'server_database.dart';

typedef Clock = DateTime Function();

class AuthService {
  AuthService({
    required ServerDatabase database,
    required String tokenSecret,
    required Duration tokenTtl,
    Clock? clock,
  }) : _database = database,
       _tokenService = AccessTokenService(
         secret: tokenSecret,
         ttl: tokenTtl,
         clock: clock,
       );

  final ServerDatabase _database;
  final AccessTokenService _tokenService;
  final _passwordHasher = PasswordHasher();

  bool get isConfigured => _tokenService.isConfigured;

  Future<AuthSession> register({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final passwordHash = _passwordHasher.hash(password);
    final user = await _database.createUser(
      email: normalizedEmail,
      passwordHash: passwordHash,
      displayName: displayName,
    );
    return _sessionFor(user);
  }

  Future<AuthSession?> login({
    required String email,
    required String password,
  }) async {
    final user = await _database.findUserByEmail(email);
    if (user == null) return null;
    if (!_passwordHasher.verify(password, user.passwordHash)) return null;
    return _sessionFor(user);
  }

  Future<StoredUser?> userForToken(String token) async {
    final claims = _tokenService.verify(token);
    if (claims == null) return null;
    return _database.findUserById(claims.subject);
  }

  AuthSession _sessionFor(StoredUser user) {
    return AuthSession(user: user, accessToken: _tokenService.create(user));
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.accessToken});

  final StoredUser user;
  final String accessToken;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'tokenType': 'Bearer',
    'user': user.toPublicJson(),
  };
}

class AccessTokenClaims {
  const AccessTokenClaims({required this.subject, required this.expiresAt});

  final String subject;
  final DateTime expiresAt;
}

class AccessTokenService {
  AccessTokenService({required String secret, required this.ttl, Clock? clock})
    : _secret = secret.trim(),
      _clock = clock ?? DateTime.now;

  final String _secret;
  final Duration ttl;
  final Clock _clock;

  bool get isConfigured => _secret.length >= 32;

  String create(StoredUser user) {
    if (!isConfigured) {
      throw StateError('AUTH_TOKEN_SECRET must be at least 32 characters.');
    }

    final issuedAt = _clock().toUtc();
    final expiresAt = issuedAt.add(ttl);
    final header = _base64UrlJson({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _base64UrlJson({
      'sub': user.id,
      'email': user.email,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    });
    final signature = _sign('$header.$payload');
    return '$header.$payload.$signature';
  }

  AccessTokenClaims? verify(String token) {
    if (!isConfigured) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final expectedSignature = _sign('${parts[0]}.${parts[1]}');
    if (!secureEquals(parts[2], expectedSignature)) return null;

    final payload = _decodeBase64UrlJson(parts[1]);
    if (payload == null) return null;

    final subject = readString(payload['sub']);
    final expiresAtSeconds = readInt(payload['exp']);
    if (subject == null || expiresAtSeconds == null) return null;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expiresAtSeconds * 1000,
      isUtc: true,
    );
    if (!expiresAt.isAfter(_clock().toUtc())) return null;

    return AccessTokenClaims(subject: subject, expiresAt: expiresAt);
  }

  String _sign(String input) {
    final digest = Hmac(
      sha256,
      utf8.encode(_secret),
    ).convert(utf8.encode(input));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}

class PasswordHasher {
  PasswordHasher({this.iterations = 120000, this.keyLength = 32});

  final int iterations;
  final int keyLength;

  String hash(String password) {
    final salt = _randomBytes(16);
    final digest = _pbkdf2(password, salt, iterations, keyLength);
    return [
      'pbkdf2_sha256',
      '$iterations',
      base64Url.encode(salt).replaceAll('=', ''),
      base64Url.encode(digest).replaceAll('=', ''),
    ].join(r'$');
  }

  bool verify(String password, String encoded) {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2_sha256') return false;

    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return false;

    final salt = _decodeBase64Url(parts[2]);
    final expected = _decodeBase64Url(parts[3]);
    if (salt == null || expected == null) return false;

    final actual = _pbkdf2(password, salt, iterations, expected.length);
    return secureEquals(base64Url.encode(actual), base64Url.encode(expected));
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

List<int> _pbkdf2(
  String password,
  List<int> salt,
  int iterations,
  int keyLength,
) {
  final hmac = Hmac(sha256, utf8.encode(password));
  final output = <int>[];
  var blockIndex = 1;

  while (output.length < keyLength) {
    var block = hmac.convert([...salt, ..._int32be(blockIndex)]).bytes;
    final accumulator = List<int>.from(block);

    for (var i = 1; i < iterations; i += 1) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < accumulator.length; j += 1) {
        accumulator[j] ^= block[j];
      }
    }

    output.addAll(accumulator);
    blockIndex += 1;
  }

  return output.take(keyLength).toList(growable: false);
}

List<int> _int32be(int value) => [
  (value >> 24) & 0xff,
  (value >> 16) & 0xff,
  (value >> 8) & 0xff,
  value & 0xff,
];

String _base64UrlJson(Map<String, dynamic> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}

Map<String, dynamic>? _decodeBase64UrlJson(String value) {
  try {
    final decoded = utf8.decode(_decodeBase64Url(value) ?? const []);
    return asStringMap(jsonDecode(decoded));
  } catch (_) {
    return null;
  }
}

List<int>? _decodeBase64Url(String value) {
  try {
    return base64Url.decode(base64Url.normalize(value));
  } catch (_) {
    return null;
  }
}
