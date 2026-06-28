import 'dart:io';

import 'rate_limiter.dart';

const defaultOpenAiModel = 'gpt-5.4-mini';
const defaultPort = 8080;
const defaultRateLimitPerMinute = 60;

class ProxyConfig {
  ProxyConfig({
    required this.port,
    required this.openAiApiKey,
    required this.foodApiKey,
    required this.clientToken,
    required this.openAiModel,
    required this.allowedOrigins,
    required this.upstreamTimeout,
    required this.upstreamClient,
    required this.rateLimiter,
  });

  final int port;
  final String openAiApiKey;
  final String foodApiKey;
  final String clientToken;
  final String openAiModel;
  final Set<String> allowedOrigins;
  final Duration upstreamTimeout;
  final HttpClient upstreamClient;
  final RateLimiter rateLimiter;

  factory ProxyConfig.fromEnvironment(Map<String, String> env) {
    final allowedOrigins = (env['ALLOWED_ORIGINS'] ?? '')
        .split(',')
        .map((origin) => origin.trim())
        .where((origin) => origin.isNotEmpty)
        .toSet();

    final rateLimit =
        int.tryParse(env['PROXY_RATE_LIMIT_PER_MINUTE'] ?? '') ??
        defaultRateLimitPerMinute;
    final openAiModel = env['OPENAI_MODEL']?.trim();

    return ProxyConfig(
      port: int.tryParse(env['PORT'] ?? '') ?? defaultPort,
      openAiApiKey: env['OPENAI_API_KEY']?.trim() ?? '',
      foodApiKey: env['FOOD_API_KEY']?.trim() ?? '',
      clientToken: env['PROXY_CLIENT_TOKEN']?.trim() ?? '',
      openAiModel: openAiModel != null && openAiModel.isNotEmpty
          ? openAiModel
          : defaultOpenAiModel,
      allowedOrigins: allowedOrigins,
      upstreamTimeout: const Duration(seconds: 30),
      upstreamClient: HttpClient()
        ..connectionTimeout = const Duration(seconds: 10),
      rateLimiter: RateLimiter(rateLimit),
    );
  }

  void close() {
    upstreamClient.close(force: true);
  }
}
