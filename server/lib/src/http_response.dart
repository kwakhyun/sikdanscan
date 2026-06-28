import 'dart:convert';
import 'dart:io';

Future<void> sendJson(
  HttpRequest request,
  Map<String, dynamic> body, {
  int statusCode = HttpStatus.ok,
}) async {
  request.response.statusCode = statusCode;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(body));
  await request.response.close();
}

Future<void> sendError(HttpRequest request, int statusCode, String message) {
  return sendJson(request, {'error': message}, statusCode: statusCode);
}
