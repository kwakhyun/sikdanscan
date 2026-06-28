import 'dart:convert';

Map<String, dynamic>? asStringMap(Object? data) {
  if (data is! Map) return null;

  return data.map((key, value) => MapEntry(key.toString(), value));
}

List<dynamic>? asList(Object? data) {
  if (data == null) return null;
  if (data is List) return data;
  return [data];
}

String? readString(Object? value) {
  final string = value?.toString().trim();
  if (string == null || string.isEmpty) return null;
  return string;
}

double readNumeric(Object? value) {
  if (value is num) {
    return value.toDouble().clamp(0.0, double.infinity).toDouble();
  }

  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return 0;

  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(raw.replaceAll(',', ''));
  final parsed = match == null ? null : double.tryParse(match.group(0)!);
  if (parsed == null || parsed < 0) return 0;
  return parsed;
}

Map<String, dynamic> decodeJsonObject(String body) {
  final decoded = jsonDecode(body);
  final map = asStringMap(decoded);
  if (map == null) {
    throw const FormatException('JSON object body is required.');
  }
  return map;
}
