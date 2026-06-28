import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/chat_message.dart';
import '../../../data/models/user_profile.dart';
import '../../../providers/service_providers.dart';
import '../../dashboard/providers/daily_health_providers.dart';
import '../../meal/providers/meal_providers.dart';
import '../../profile/providers/profile_providers.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      final language = ref.watch(languageProvider).languageCode;
      return ChatMessagesNotifier(ref, language);
    });

final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this._ref, this._languageCode)
    : super([
        ChatMessage(
          id: 'welcome',
          content: _welcomeMessage(_languageCode),
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          type: ChatMessageType.text,
        ),
      ]);

  final Ref _ref;
  final String _languageCode;

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  Future<void> addBotResponse(String userMessage) async {
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      final aiService = _ref.read(aiChatServiceProvider);
      final context = _buildUserContext();

      final response = await aiService.generateResponse(
        userMessage: userMessage,
        context: context,
        locale: _languageCode,
      );

      addMessage(
        ChatMessage(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
          type: ChatMessageType.text,
        ),
      );
    } catch (e) {
      addMessage(
        ChatMessage(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          content: _isEnglish
              ? 'Sorry, a temporary error occurred.\nPlease ask again and I will help you.'
              : '죄송해요, 일시적인 오류가 발생했어요.\n다시 질문해주시면 답변드릴게요!',
          isUser: false,
          timestamp: DateTime.now(),
          type: ChatMessageType.text,
        ),
      );
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  Map<String, dynamic> _buildUserContext() {
    final profile = _ref.read(userProfileProvider);
    final todayCalories = _ref.read(todayCaloriesProvider);
    final macros = _ref.read(todayMacrosProvider);
    final health = _ref.read(dailyHealthProvider);

    return {
      'todayCalories': todayCalories,
      'calorieGoal': profile.dailyCalorieGoal,
      'currentWeight': profile.currentWeight,
      'targetWeight': profile.targetWeight,
      'wellnessGoal': _goalLabel(profile.wellnessGoal),
      'wellnessGoalDescription': profile.wellnessGoal.description,
      'waterMl': health.waterMl,
      'steps': health.steps,
      'macros': macros,
    };
  }

  bool get _isEnglish => _languageCode.toLowerCase().startsWith('en');

  static String _welcomeMessage(String languageCode) {
    if (languageCode.toLowerCase().startsWith('en')) {
      return 'Hi, I am the SikdanScan AI Coach.\n\nWhat would you like to know about today’s meals or your goal strategy?';
    }
    return '안녕하세요. 저는 식단스캔 AI 코치입니다.\n\n오늘 식단이나 목표별 개선 전략에 대해 궁금한 점이 있으신가요?';
  }

  String _goalLabel(WellnessGoal goal) {
    if (!_isEnglish) return goal.label;
    return switch (goal) {
      WellnessGoal.balanced => 'Balanced care',
      WellnessGoal.weightLoss => 'Weight loss',
      WellnessGoal.skinHealth => 'Skin health',
      WellnessGoal.digestion => 'Digestion',
      WellnessGoal.energy => 'Energy',
      WellnessGoal.muscle => 'Protein boost',
      WellnessGoal.glucose => 'Glucose stability',
    };
  }
}
