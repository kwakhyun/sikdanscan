import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'json_helpers.dart';
import 'proxy_config.dart';
import 'proxy_exceptions.dart';

Future<Map<String, dynamic>> getPublicFoodPayload(
  ProxyConfig config,
  String query,
) async {
  final uri = Uri.https(
    'apis.data.go.kr',
    '/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02',
    {
      'serviceKey': config.foodApiKey,
      'pageNo': '1',
      'numOfRows': '20',
      'type': 'json',
      'FOOD_NM_KR': query,
    },
  );

  return sendUpstreamJsonRequest(config, uri);
}

Future<Map<String, dynamic>> postOpenAiChat(
  ProxyConfig config,
  Map<String, dynamic> payload,
) {
  return sendUpstreamJsonRequest(
    config,
    Uri.https('api.openai.com', '/v1/chat/completions'),
    method: 'POST',
    headers: {'Authorization': 'Bearer ${config.openAiApiKey}'},
    body: payload,
  );
}

Future<Map<String, dynamic>> sendUpstreamJsonRequest(
  ProxyConfig config,
  Uri uri, {
  String method = 'GET',
  Map<String, String>? headers,
  Map<String, dynamic>? body,
}) async {
  try {
    final upstreamRequest =
        await (method == 'POST'
                ? config.upstreamClient.postUrl(uri)
                : config.upstreamClient.getUrl(uri))
            .timeout(config.upstreamTimeout);

    upstreamRequest.headers.contentType = ContentType.json;
    headers?.forEach(upstreamRequest.headers.set);

    if (body != null) {
      upstreamRequest.write(jsonEncode(body));
    }

    final response = await upstreamRequest.close().timeout(
      config.upstreamTimeout,
    );
    final responseBody = await utf8.decoder.bind(response).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UpstreamException(
        response.statusCode,
        readUpstreamErrorMessage(responseBody),
      );
    }

    final map = asStringMap(jsonDecode(responseBody));
    if (map == null) {
      throw const UpstreamException(HttpStatus.badGateway);
    }

    return map;
  } on TimeoutException {
    throw const UpstreamException(HttpStatus.gatewayTimeout);
  } on FormatException {
    throw const UpstreamException(HttpStatus.badGateway);
  } on IOException {
    throw const UpstreamException(HttpStatus.badGateway);
  }
}

String? readUpstreamErrorMessage(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    final map = asStringMap(decoded);
    if (map == null) return null;

    final error = map['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    final errorMap = asStringMap(error);
    final message = readString(errorMap?['message']);
    final code = readString(errorMap?['code']);
    final type = readString(errorMap?['type']);

    final parts = [
      if (message != null) message,
      if (code != null) 'code=$code',
      if (type != null) 'type=$type',
    ];
    if (parts.isEmpty) return null;

    return parts.join(' ');
  } catch (_) {
    return null;
  }
}

String? extractOpenAiContent(Map<String, dynamic> data) {
  final choices = data['choices'];
  if (choices is! List || choices.isEmpty) return null;

  final firstChoice = asStringMap(choices.first);
  final message = asStringMap(firstChoice?['message']);
  return readString(message?['content']);
}
