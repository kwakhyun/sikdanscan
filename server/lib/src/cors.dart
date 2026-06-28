import 'dart:io';

import 'proxy_config.dart';

bool applyCorsHeaders(HttpRequest request, ProxyConfig config) {
  final origin = request.headers.value('origin');
  final allowAll = config.allowedOrigins.isEmpty;

  if (origin != null && origin.isNotEmpty) {
    if (!allowAll && !config.allowedOrigins.contains(origin)) {
      return false;
    }

    request.response.headers
      ..set(HttpHeaders.accessControlAllowOriginHeader, allowAll ? '*' : origin)
      ..set(HttpHeaders.accessControlAllowMethodsHeader, 'GET, POST, OPTIONS')
      ..set(
        HttpHeaders.accessControlAllowHeadersHeader,
        'Content-Type, Authorization',
      );
    return true;
  }

  request.response.headers
    ..set(
      HttpHeaders.accessControlAllowOriginHeader,
      allowAll ? '*' : config.allowedOrigins.first,
    )
    ..set(HttpHeaders.accessControlAllowMethodsHeader, 'GET, POST, OPTIONS')
    ..set(
      HttpHeaders.accessControlAllowHeadersHeader,
      'Content-Type, Authorization',
    );
  return true;
}
