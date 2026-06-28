class ClientException implements Exception {
  const ClientException(this.statusCode, this.message);

  final int statusCode;
  final String message;
}

class UpstreamException implements Exception {
  const UpstreamException(this.statusCode, [this.message]);

  final int statusCode;
  final String? message;
}
