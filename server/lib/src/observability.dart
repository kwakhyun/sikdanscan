import 'dart:convert';
import 'dart:io';
import 'dart:math';

class ProxyMetrics {
  final Map<String, int> _requestCounts = {};
  final Map<String, int> _latencyMsSums = {};

  void record({
    required String method,
    required String path,
    required int statusCode,
    required int durationMs,
  }) {
    final route = _normalizeRoute(path);
    final statusClass = '${statusCode ~/ 100}xx';
    final key = '$method|$route|$statusClass';
    _requestCounts[key] = (_requestCounts[key] ?? 0) + 1;
    _latencyMsSums[key] = (_latencyMsSums[key] ?? 0) + durationMs;
  }

  Map<String, dynamic> snapshot() => {
    'requests': _requestCounts.map((key, value) => MapEntry(key, value)),
    'latencyMsSum': _latencyMsSums.map((key, value) => MapEntry(key, value)),
  };

  String toPrometheus() {
    final lines = <String>[
      '# HELP sikdanscan_proxy_requests_total Total proxy HTTP requests.',
      '# TYPE sikdanscan_proxy_requests_total counter',
    ];

    for (final entry in _requestCounts.entries) {
      final labels = _labels(entry.key);
      lines.add('sikdanscan_proxy_requests_total{$labels} ${entry.value}');
    }

    lines.addAll([
      '# HELP sikdanscan_proxy_request_duration_ms_sum Total proxy request duration in milliseconds.',
      '# TYPE sikdanscan_proxy_request_duration_ms_sum counter',
    ]);

    for (final entry in _latencyMsSums.entries) {
      final labels = _labels(entry.key);
      lines.add(
        'sikdanscan_proxy_request_duration_ms_sum{$labels} ${entry.value}',
      );
    }

    return '${lines.join('\n')}\n';
  }

  String _labels(String key) {
    final parts = key.split('|');
    return 'method="${parts[0]}",route="${parts[1]}",status_class="${parts[2]}"';
  }
}

class ProxyLogger {
  const ProxyLogger();

  void request({
    required String requestId,
    required String method,
    required String path,
    required int statusCode,
    required int durationMs,
    required String remoteAddress,
  }) {
    stdout.writeln(
      jsonEncode({
        'ts': DateTime.now().toUtc().toIso8601String(),
        'level': statusCode >= 500 ? 'error' : 'info',
        'event': 'http_request',
        'requestId': requestId,
        'method': method,
        'path': path,
        'statusCode': statusCode,
        'durationMs': durationMs,
        'remoteAddress': remoteAddress,
      }),
    );
  }

  void startup({required int port, required String database}) {
    stdout.writeln(
      jsonEncode({
        'ts': DateTime.now().toUtc().toIso8601String(),
        'level': 'info',
        'event': 'proxy_startup',
        'port': port,
        'database': database,
      }),
    );
  }
}

String ensureRequestId(HttpRequest request) {
  final existing = request.headers.value('x-request-id')?.trim();
  final requestId = existing != null && existing.isNotEmpty
      ? existing
      : _generateRequestId();
  request.response.headers.set('x-request-id', requestId);
  return requestId;
}

String _generateRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(12, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

String _normalizeRoute(String path) {
  if (path.startsWith('/v1/me/meals')) return '/v1/me/meals';
  return path;
}
