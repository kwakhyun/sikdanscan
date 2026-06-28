import 'dart:convert';
import 'dart:io';

const proxyDotenvFiles = ['.env.proxy', '.env'];

Map<String, String> loadProxyEnvironment(
  Map<String, String> environment, {
  Directory? directory,
  Iterable<String> fileNames = proxyDotenvFiles,
}) {
  final merged = Map<String, String>.of(environment);
  final sourceDirectory = directory ?? Directory.current;

  for (final fileName in fileNames) {
    final file = File('${sourceDirectory.path}/$fileName');
    if (!file.existsSync()) continue;

    final values = parseProxyDotenv(file.readAsStringSync());
    for (final entry in values.entries) {
      merged.putIfAbsent(entry.key, () => entry.value);
    }
  }

  return merged;
}

Map<String, String> parseProxyDotenv(String contents) {
  final values = <String, String>{};

  for (final rawLine in const LineSplitter().convert(contents)) {
    var line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    if (line.startsWith('export ')) {
      line = line.substring('export '.length).trim();
    }

    final separator = line.indexOf('=');
    if (separator <= 0) continue;

    final key = line.substring(0, separator).trim();
    if (!_isValidEnvKey(key)) continue;

    final value = line.substring(separator + 1).trim();
    values[key] = _stripOptionalQuotes(value);
  }

  return values;
}

bool _isValidEnvKey(String key) {
  return RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(key);
}

String _stripOptionalQuotes(String value) {
  if (value.length < 2) return value;

  final first = value[0];
  final last = value[value.length - 1];
  if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
    return value.substring(1, value.length - 1);
  }

  return value;
}
