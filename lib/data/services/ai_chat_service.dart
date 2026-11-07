import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'proxy_client_config.dart';

/// A single turn sent to the coach as conversation history.
class AiChatTurn {
  const AiChatTurn({required this.isUser, required this.content});

  final bool isUser;
  final String content;

  Map<String, String> toJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': content,
  };
}

/// Coach answer plus whether it came from the AI server or the local
/// keyword fallback, so the UI never presents canned text as AI output.
class AiChatReply {
  const AiChatReply({
    required this.content,
    this.isFallback = false,
    this.quotaExceeded = false,
  });

  final String content;
  final bool isFallback;
  final bool quotaExceeded;
}

class AiChatService {
  /// Turns of prior conversation sent with each request.
  static const maxHistoryTurns = 10;
  // Keeps the request well under the proxy 32KB body limit (UTF-8 Hangul is
  // 3 bytes per character).
  static const _maxTurnLength = 600;

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

  /// Returns the coach reply. Throws when the server is configured but the
  /// request fails for a reason other than quota, so the UI can offer retry.
  Future<AiChatReply> reply({
    required String userMessage,
    List<AiChatTurn> history = const [],
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) async {
    if (!isConfigured) {
      return AiChatReply(
        content: fallbackResponse(userMessage, locale: locale),
        isFallback: true,
      );
    }

    try {
      final response = await _apiService.post(
        _proxyConfig.baseUrl,
        ApiConstants.proxyChatEndpoint,
        data: {
          'message': userMessage,
          'locale': _normalizeLocale(locale),
          'history': trimHistory(history).map((turn) => turn.toJson()).toList(),
          if (context != null) 'context': context,
        },
        headers: _proxyConfig.authHeaders,
      );

      final content = _extractProxyContent(response.data);
      if (content != null && content.isNotEmpty) {
        return AiChatReply(content: content);
      }
      throw const AiChatException('empty_response');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('insufficient_quota') ||
          errorMsg.contains('RATE_LIMIT')) {
        return AiChatReply(
          content: fallbackResponse(userMessage, locale: locale),
          isFallback: true,
          quotaExceeded: true,
        );
      }
      // Unreachable server (offline, proxy down): answer with the local tips,
      // clearly labelled as offline, instead of an error bubble.
      if (_isConnectivityError(e)) {
        return AiChatReply(
          content: fallbackResponse(userMessage, locale: locale),
          isFallback: true,
        );
      }
      rethrow;
    }
  }

  static bool _isConnectivityError(Object error) {
    if (error is! DioException) return false;
    final apiError = error.error;
    if (apiError is ApiError) {
      return apiError.code == 'NO_CONNECTION' || apiError.code == 'TIMEOUT';
    }
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  /// Backwards-compatible single-string API.
  Future<String> generateResponse({
    required String userMessage,
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) async {
    try {
      final result = await reply(
        userMessage: userMessage,
        context: context,
        locale: locale,
      );
      return result.content;
    } catch (_) {
      return fallbackResponse(userMessage, locale: locale);
    }
  }

  /// Keeps the most recent turns and truncates very long ones.
  static List<AiChatTurn> trimHistory(List<AiChatTurn> history) {
    final recent = history.length > maxHistoryTurns
        ? history.sublist(history.length - maxHistoryTurns)
        : history;
    return recent
        .where((turn) => turn.content.trim().isNotEmpty)
        .map(
          (turn) => AiChatTurn(
            isUser: turn.isUser,
            content: turn.content.length > _maxTurnLength
                ? turn.content.substring(0, _maxTurnLength)
                : turn.content,
          ),
        )
        .toList(growable: false);
  }

  String? _extractProxyContent(Object? responseData) {
    if (responseData is! Map) return null;

    final content = responseData['content'];
    if (content is! String) return null;

    return content.trim();
  }

  String fallbackResponse(String message, {String locale = 'ko'}) {
    final lowerMessage = message.toLowerCase();
    if (_isEnglish(locale)) {
      return _englishFallback(lowerMessage);
    }

    if (_containsAny(lowerMessage, const ['칼로리', '열량'])) {
      return '칼로리는 식단 전략의 기준점이에요.\n\n개인 목표 칼로리는 나이·키·체중·활동량으로 계산되며, 프로필의 "일일 목표 칼로리 기준"에서 확인할 수 있어요.\n\n데일리 화면에서 남은 칼로리를 보고 다음 식사는 단백질과 채소부터 채워보세요.';
    }

    if (_containsAny(lowerMessage, const ['운동', '헬스', '트레이닝'])) {
      return '식단 목표와 함께하기 좋은 운동이에요.\n\n1. 식후 10분 걷기\n2. 스쿼트 3세트 x 15회\n3. 플랭크 3세트 x 30초\n4. 가벼운 스트레칭 5분\n\n통증이나 질환이 있다면 전문가와 먼저 상의하세요.';
    }

    if (_containsAny(lowerMessage, const ['물', '수분'])) {
      return '수분은 피부, 소화, 컨디션 목표 모두에 중요해요.\n\n• 식전 30분 물 한 잔\n• 하루 참고량: 체중(kg) × 30ml\n• 데일리 화면의 수분 카드에서 한 잔씩 기록\n\n짜거나 기름진 식사 뒤에는 조금 더 보강하세요.';
    }

    if (_containsAny(lowerMessage, const ['체중', '몸무게'])) {
      return '체중은 하루 값보다 추이가 중요해요.\n\n주당 0.5~1kg 정도의 완만한 변화가 유지하기 좋아요. 프로필의 체중 기록에서 같은 시간대에 꾸준히 기록하고 추이를 확인해보세요.';
    }

    if (_containsAny(lowerMessage, const ['간식', '야식'])) {
      return '부담이 적은 간식 예시예요.\n\n• 그릭요거트 + 베리류\n• 삶은 계란 2개\n• 견과류 한 줌\n• 당근 스틱 + 후무스\n\n야식이 당길 때는 따뜻한 차를 먼저 마셔보세요.';
    }

    if (_containsAny(lowerMessage, const ['안녕', '하이', '반가'])) {
      return '안녕하세요.\n\n이런 것들을 물어볼 수 있어요:\n• 오늘 식단 분석\n• 다음 식사 추천\n• 운동 루틴\n• 수분·간식 팁';
    }

    return '목표별 식단 개선의 기본 팁이에요.\n\n1. 매끼 단백질 포함\n2. 채소와 식이섬유 보강\n3. 수분 함께 기록\n4. 식후 10분 걷기\n5. 사진 기록으로 패턴 확인';
  }

  String _englishFallback(String lowerMessage) {
    if (_containsWord(lowerMessage, const ['calorie', 'calories', 'kcal'])) {
      return 'Calories are the baseline for meal strategy.\n\nYour personal target is calculated from age, height, weight and activity — see "Daily calorie basis" in Profile.\n\nCheck what is left in Daily and build the next meal with protein and vegetables first.';
    }

    if (_containsWord(lowerMessage, const [
      'exercise',
      'workout',
      'training',
    ])) {
      return 'Simple activities that pair well with meal goals:\n\n1. Walk 10 minutes after meals\n2. Squats 3 x 15\n3. Plank 3 x 30 seconds\n4. Light stretching for 5 minutes\n\nCheck with a professional first if you have pain or a condition.';
    }

    if (_containsWord(lowerMessage, const ['water', 'hydration', 'drink'])) {
      return 'Hydration supports skin, digestion and energy goals.\n\n• A glass of water 30 minutes before meals\n• Baseline: body weight (kg) x 30ml\n• Log each glass on the water card in Daily';
    }

    if (_containsWord(lowerMessage, const ['weight'])) {
      return 'Weight trends matter more than a single day.\n\nA steady change of about 0.5–1kg per week is sustainable. Log your weight in Profile at the same time of day and watch the trend.';
    }

    if (_containsWord(lowerMessage, const ['snack', 'snacks', 'late'])) {
      return 'Balanced snack ideas:\n\n• Greek yogurt with berries\n• Two boiled eggs\n• A small handful of nuts\n• Carrot sticks with hummus';
    }

    if (_containsWord(lowerMessage, const ['hi', 'hello', 'hey'])) {
      return 'Hi.\n\nYou can ask me about:\n• Today’s meals\n• What to eat next\n• Exercise routines\n• Hydration and snack tips';
    }

    return 'Basics for goal-based eating:\n\n1. Include protein in each meal\n2. Add vegetables and fiber\n3. Track hydration\n4. Walk 10 minutes after meals\n5. Use photo logs to spot patterns';
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  /// Whole-word match so "this" or "which" never count as "hi".
  static bool _containsWord(String text, List<String> words) {
    return words.any(
      (word) =>
          RegExp('(^|[^a-z])${RegExp.escape(word)}([^a-z]|\$)').hasMatch(text),
    );
  }

  String _normalizeLocale(String locale) => _isEnglish(locale) ? 'en' : 'ko';

  bool _isEnglish(String locale) => locale.toLowerCase().startsWith('en');
}

class AiChatException implements Exception {
  const AiChatException(this.code);

  final String code;

  @override
  String toString() => 'AiChatException($code)';
}
