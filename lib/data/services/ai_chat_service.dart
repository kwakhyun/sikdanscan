import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'proxy_client_config.dart';

class AiChatService {
  final ApiService _apiService;
  final ProxyClientConfig _proxyConfig;

  AiChatService({
    ApiService? apiService,
    String? proxyBaseUrl,
    String? proxyClientToken,
    ProxyClientConfig? proxyConfig,
  }) : _apiService = apiService ?? ApiService(),
       _proxyConfig =
           proxyConfig ??
           ProxyClientConfig.fromEnvironment(
             baseUrlOverride: proxyBaseUrl,
             clientTokenOverride: proxyClientToken,
           );

  bool get isConfigured => _proxyConfig.isConfigured;

  Future<String> generateResponse({
    required String userMessage,
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) async {
    if (!isConfigured) {
      return _generateFallbackResponse(userMessage, locale: locale);
    }

    try {
      final response = await _apiService.post(
        _proxyConfig.baseUrl,
        ApiConstants.proxyChatEndpoint,
        data: {
          'message': userMessage,
          'locale': _normalizeLocale(locale),
          if (context != null) 'context': context,
        },
        headers: _proxyConfig.authHeaders,
      );

      final content = _extractProxyContent(response.data);
      if (content != null && content.isNotEmpty) {
        return content;
      }

      return _generateFallbackResponse(userMessage, locale: locale);
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('insufficient_quota') ||
          errorMsg.contains('RATE_LIMIT')) {
        final fallback = _generateFallbackResponse(userMessage, locale: locale);
        final notice = _isEnglish(locale)
            ? 'The AI server quota is currently exceeded, so a local response is shown.'
            : '현재 AI 서버 사용량이 초과되어 로컬 응답을 표시합니다.';
        return '$fallback\n\n---\n$notice';
      }
      return _generateFallbackResponse(userMessage, locale: locale);
    }
  }

  String? _extractProxyContent(Object? responseData) {
    if (responseData is! Map) return null;

    final content = responseData['content'];
    if (content is! String) return null;

    return content.trim();
  }

  String _generateFallbackResponse(String message, {String locale = 'ko'}) {
    final lowerMessage = message.toLowerCase();
    if (_isEnglish(locale)) {
      return _generateEnglishFallbackResponse(lowerMessage);
    }

    if (lowerMessage.contains('칼로리') || lowerMessage.contains('열량')) {
      return '칼로리는 식단 전략의 중요한 기준이에요.\n\n일반적으로 성인 여성 1,200~1,500kcal, 남성 1,500~1,800kcal 범위를 참고할 수 있습니다.\n\n데일리에서 오늘 섭취량과 목표별 전략을 함께 확인해보세요.';
    }

    if (lowerMessage.contains('운동') ||
        lowerMessage.contains('헬스') ||
        lowerMessage.contains('트레이닝')) {
      return '식단 목표와 함께하기 좋은 활동을 추천해드릴게요.\n\n1. 식후 10분 걷기\n2. 스쿼트 3세트 x 15회\n3. 플랭크 3세트 x 30초\n4. 가벼운 스트레칭 5분\n\n운동보다 먼저 식사 기록과 회복 루틴을 꾸준히 맞춰보세요.';
    }

    if (lowerMessage.contains('물') || lowerMessage.contains('수분')) {
      return '수분 섭취는 피부, 소화, 컨디션 목표 모두에 중요해요.\n\n• 식전 30분 물 한 잔\n• 하루 참고량: 체중(kg) × 30ml\n• 카페인 음료는 물과 따로 기록\n\n오늘 식단이 짜거나 기름졌다면 물을 조금 더 보강하세요.';
    }

    if (lowerMessage.contains('체중') || lowerMessage.contains('몸무게')) {
      return '건강한 체중 감량 팁입니다.\n\n주당 0.5~1kg 감량이 이상적입니다.\n\n급격한 감량은 요요현상의 원인이 돼요. 꾸준하게 기록하고 추이를 확인하는 것이 가장 중요합니다.\n\n체중 기록 탭에서 변화 추이를 확인해보세요.';
    }

    if (lowerMessage.contains('간식') || lowerMessage.contains('야식')) {
      return '건강한 간식을 추천해드릴게요.\n\n• 그릭요거트 + 베리류 (130kcal)\n• 삶은 계란 2개 (156kcal)\n• 견과류 한줌 (180kcal)\n• 당근 스틱 + 후무스 (100kcal)\n• 프로틴 쉐이크 (150kcal)\n\n야식이 당길 때는 따뜻한 허브차를 마셔보세요.';
    }

    if (lowerMessage.contains('안녕') ||
        lowerMessage.contains('하이') ||
        lowerMessage.contains('hi')) {
      return '안녕하세요.\n\n오늘도 건강한 하루 보내고 계신가요?\n\n궁금한 점이 있으시면 편하게 물어보세요:\n• 식단 추천\n• 운동 추천\n• 칼로리 분석\n• 체중 추이\n• 수분 섭취 팁';
    }

    return '좋은 질문이에요.\n\n목표별 식단 개선을 위한 핵심 팁:\n\n1. 매끼 단백질을 포함하세요\n2. 수분을 함께 기록하세요\n3. 채소와 식이섬유를 보강하세요\n4. 식후 10분 걷기를 시도하세요\n5. 사진 기록으로 패턴을 확인하세요\n\n피부, 감량, 장 건강 중 어떤 목표인지 알려주시면 더 구체적으로 도와드릴게요.';
  }

  String _generateEnglishFallbackResponse(String lowerMessage) {
    if (lowerMessage.contains('calorie') || lowerMessage.contains('kcal')) {
      return 'Calories are an important baseline for meal strategy.\n\nCheck today’s intake against your goal in Daily, then adjust the next meal with protein, vegetables, and hydration first.';
    }

    if (lowerMessage.contains('exercise') ||
        lowerMessage.contains('workout') ||
        lowerMessage.contains('training')) {
      return 'Here are simple activities that pair well with meal goals.\n\n1. Walk 10 minutes after meals\n2. Squats 3 x 15\n3. Plank 3 x 30 seconds\n4. Light stretching for 5 minutes';
    }

    if (lowerMessage.contains('water') || lowerMessage.contains('hydration')) {
      return 'Hydration supports skin, digestion, and energy goals.\n\n• Drink water 30 minutes before meals\n• Use body weight(kg) x 30ml as a baseline\n• Add extra water after salty or oily meals';
    }

    if (lowerMessage.contains('weight')) {
      return 'Healthy weight change is gradual.\n\nA steady trend matters more than a single day. Keep recording meals and review your report to spot patterns.';
    }

    if (lowerMessage.contains('snack') || lowerMessage.contains('late')) {
      return 'Here are balanced snack ideas.\n\n• Greek yogurt with berries\n• Two boiled eggs\n• A small handful of nuts\n• Carrot sticks with hummus\n• Protein shake';
    }

    if (lowerMessage.contains('hi') || lowerMessage.contains('hello')) {
      return 'Hi.\n\nHow is your day going? Ask me about meal ideas, exercise, calorie analysis, weight trends, or hydration tips.';
    }

    return 'Good question.\n\nFor better meal strategy, start with these basics:\n\n1. Include protein in each meal\n2. Track hydration\n3. Add vegetables and fiber\n4. Walk 10 minutes after meals\n5. Use photo logs to find patterns';
  }

  String _normalizeLocale(String locale) => _isEnglish(locale) ? 'en' : 'ko';

  bool _isEnglish(String locale) => locale.toLowerCase().startsWith('en');
}
