import 'dart:io';

import 'auth_service.dart';
import 'observability.dart';
import 'rate_limiter.dart';
import 'server_database.dart';

const defaultOpenAiModel = 'gpt-5.4-mini';
const defaultPort = 8080;
const defaultRateLimitPerMinute = 60;
const defaultDatabasePath = '.sikdanscan_proxy_db.json';
const defaultAuthTokenTtlMinutes = 60 * 24 * 30;

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
    required this.database,
    required this.authService,
    required this.metrics,
    required this.logger,
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
  final ServerDatabase database;
  final AuthService authService;
  final ProxyMetrics metrics;
  final ProxyLogger logger;

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
    final databasePath = env['DATABASE_PATH']?.trim();
    final authSecret = env['AUTH_TOKEN_SECRET']?.trim() ?? '';
    final authTtlMinutes =
        int.tryParse(env['AUTH_TOKEN_TTL_MINUTES'] ?? '') ??
        defaultAuthTokenTtlMinutes;
    final database = FileServerDatabase(
      databasePath != null && databasePath.isNotEmpty
          ? databasePath
          : defaultDatabasePath,
    );

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
      database: database,
      authService: AuthService(
        database: database,
        tokenSecret: authSecret,
        tokenTtl: Duration(minutes: authTtlMinutes),
      ),
      metrics: ProxyMetrics(),
      logger: const ProxyLogger(),
    );
  }

  void close() {
    upstreamClient.close(force: true);
    database.close();
  }
}
