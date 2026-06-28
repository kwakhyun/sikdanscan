class ApiConstants {
  ApiConstants._();

  static const String proxyBaseUrlEnv = 'SIKDANSCAN_PROXY_BASE_URL';
  static const String proxyClientTokenEnv = 'SIKDANSCAN_PROXY_CLIENT_TOKEN';
  static const String proxyHealthEndpoint = '/health';
  static const String proxyChatEndpoint = '/v1/chat';
  static const String proxyFoodPublicEndpoint = '/v1/foods/public';
  static const String proxyFoodAnalyzeEndpoint = '/v1/foods/analyze';
  static const String proxyFoodRecognizeEndpoint = '/v1/foods/recognize';

  static const String nutritionixBaseUrl =
      'https://trackapi.nutritionix.com/v2';
  static const String nutritionixSearchEndpoint = '/search/instant';

  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;
}
