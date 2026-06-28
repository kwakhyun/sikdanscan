import 'dart:convert';
import 'dart:io';

import 'proxy_config.dart';
import 'proxy_exceptions.dart';

ClientException? validateClientAuthorization(
  HttpRequest request,
  ProxyConfig config,
) {
  return validateClientAuthorizationHeader(
    request.headers.value(HttpHeaders.authorizationHeader),
    config.clientToken,
  );
}

ClientException? validateClientAuthorizationHeader(
  String? authorization,
  String expectedToken,
) {
  if (expectedToken.isEmpty) return null;

  if (authorization == null || authorization.trim().isEmpty) {
    return const ClientException(
      HttpStatus.unauthorized,
      'Proxy client token is required.',
    );
  }

  final token = readBearerToken(authorization);
  if (token == null || !secureEquals(token, expectedToken)) {
    return const ClientException(
      HttpStatus.forbidden,
      'Proxy client token is invalid.',
    );
  }

  return null;
}

String? readBearerToken(String authorization) {
  final match = RegExp(
    r'^Bearer\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(authorization.trim());
  return match?.group(1)?.trim();
}

bool secureEquals(String left, String right) {
  final leftBytes = utf8.encode(left);
  final rightBytes = utf8.encode(right);
  final maxLength = leftBytes.length > rightBytes.length
      ? leftBytes.length
      : rightBytes.length;

  var difference = leftBytes.length ^ rightBytes.length;
  for (var i = 0; i < maxLength; i += 1) {
    final leftValue = i < leftBytes.length ? leftBytes[i] : 0;
    final rightValue = i < rightBytes.length ? rightBytes[i] : 0;
    difference |= leftValue ^ rightValue;
  }

  return difference == 0;
}
