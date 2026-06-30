import 'dart:convert';
import 'dart:io';

import 'json_helpers.dart';
import 'proxy_exceptions.dart';

const maxRequestBodyBytes = 32 * 1024;
const maxImageRecognitionBodyBytes = 6 * 1024 * 1024;

Future<Map<String, dynamic>> readJsonObject(
  HttpRequest request, {
  int maxBytes = maxRequestBodyBytes,
}) async {
  if (request.contentLength > maxBytes) {
    await request.drain<void>();
    throw const ClientException(
      HttpStatus.requestEntityTooLarge,
      'Request body is too large.',
    );
  }

  final chunks = <int>[];
  await for (final chunk in request) {
    chunks.addAll(chunk);
    if (chunks.length > maxBytes) {
      throw const ClientException(
        HttpStatus.requestEntityTooLarge,
        'Request body is too large.',
      );
    }
  }

  if (chunks.isEmpty) return {};

  return decodeJsonObject(utf8.decode(chunks));
}
