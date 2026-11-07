import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/ai_chat_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/service_providers.dart';
import '../../dashboard/providers/daily_health_providers.dart';
import '../../dashboard/providers/meal_strategy_providers.dart';
import '../../meal/providers/meal_providers.dart';
import '../../profile/providers/profile_providers.dart';

/// Persisted conversation with the AI coach. The welcome message is rendered
/// by the screen (in the current language) and is not part of the history.
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      return ChatMessagesNotifier(ref, ref.read(localStorageServiceProvider));
    });

final chatLoadingProvider = StateProvider<bool>((ref) => false);

/// Whether answers currently come from the AI server: the proxy must be
/// configured and the latest answer must not have been an offline fallback.
final chatOnlineProvider = Provider<bool>((ref) {
  if (!ref.watch(aiChatServiceProvider).isConfigured) return false;
  final messages = ref.watch(chatMessagesProvider);
  for (final message in messages.reversed) {
    if (message.isUser) continue;
    return message.type != ChatMessageType.offline;
  }
  return true;
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this._ref, this._storage) : super(_load(_storage));

  static const maxStoredMessages = 80;
  static const _uuid = Uuid();

  final Ref _ref;
  final LocalStorageService _storage;

  static List<ChatMessage> _load(LocalStorageService storage) {
    try {
      return PersistedModelDecoder.list(
        storage.getChatHistory(),
        PersistedModelDecoder.chatMessage,
      );
    } catch (_) {
      return const [];
    }
  }

  bool get _isLoading => _ref.read(chatLoadingProvider);

  /// Adds the user's message and requests a reply.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _append(
      ChatMessage(
        id: _uuid.v4(),
        content: trimmed,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    await _requestReply(trimmed);
  }

  /// Re-sends the user message that preceded the last failed reply.
  Future<void> retryLast() async {
    if (_isLoading || state.isEmpty) return;
    final last = state.last;
    if (last.type != ChatMessageType.error) return;

    final withoutError = state.sublist(0, state.length - 1);
    final lastUser = withoutError.lastWhere(
      (message) => message.isUser,
      orElse: () => last,
    );
    if (!lastUser.isUser) return;

    state = withoutError;
    await _persist();
    await _requestReply(lastUser.content);
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  Future<void> _requestReply(String userMessage) async {
    _ref.read(chatLoadingProvider.notifier).state = true;
    try {
      final service = _ref.read(aiChatServiceProvider);
      final reply = await service.reply(
        userMessage: userMessage,
        history: _historyBefore(userMessage),
        context: buildCoachContext(),
        locale: _ref.read(resolvedLanguageCodeProvider),
      );
      _append(
        ChatMessage(
          id: 'bot_${_uuid.v4()}',
          content: reply.content,
          isUser: false,
          timestamp: DateTime.now(),
          type: reply.isFallback
              ? ChatMessageType.offline
              : ChatMessageType.text,
        ),
      );
    } catch (_) {
      _append(
        ChatMessage(
          id: 'error_${_uuid.v4()}',
          content: '',
          isUser: false,
          timestamp: DateTime.now(),
          type: ChatMessageType.error,
        ),
      );
    } finally {
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }

  /// Prior turns (excluding the message being answered and failed replies).
  List<AiChatTurn> _historyBefore(String userMessage) {
    final turns = state
        .where(
          (message) =>
              message.type != ChatMessageType.error &&
              message.content.trim().isNotEmpty,
        )
        .toList();
    if (turns.isNotEmpty &&
        turns.last.isUser &&
        turns.last.content == userMessage) {
      turns.removeLast();
    }
    return AiChatService.trimHistory(
      turns
          .map((m) => AiChatTurn(isUser: m.isUser, content: m.content))
          .toList(),
    );
  }

  /// Today's data the coach grounds its answers in.
  Map<String, dynamic> buildCoachContext() {
    final profile = _ref.read(userProfileProvider);
    final meals = _ref.read(todayMealsProvider);
    final macros = _ref.read(todayMacrosProvider);
    final health = _ref.read(dailyHealthProvider);
    final weight = _ref.read(currentWeightProvider);
    final english = _ref.read(resolvedLanguageCodeProvider) == 'en';

    return {
      'todayCalories': _ref.read(todayCaloriesProvider),
      'calorieGoal': profile.dailyCalorieGoal,
      'currentWeight': weight,
      'targetWeight': profile.targetWeight,
      'wellnessGoal': _goalLabel(profile.wellnessGoal, english: english),
      if (!english) 'wellnessGoalDescription': profile.wellnessGoal.description,
      'proteinGoal': MealStrategyBuilder.proteinGoal(
        profile.copyWith(currentWeight: weight),
      ).round(),
      'waterMl': health.waterMl,
      if (profile.dailyWaterGoalMl > 0) 'waterGoalMl': profile.dailyWaterGoalMl,
      'macros': macros,
      'meals': [
        for (final meal in meals)
          {
            'name': meal.name,
            'calories': meal.calories,
            'mealType': meal.mealType.name,
            'time': AppFormat.time(meal.date),
          },
      ],
    };
  }

  void _append(ChatMessage message) {
    state = [...state, message];
    _persist();
  }

  Future<void> _persist() async {
    final messages = state.length > maxStoredMessages
        ? state.sublist(state.length - maxStoredMessages)
        : state;
    try {
      await _storage.saveChatHistory(messages.map((m) => m.toJson()).toList());
    } catch (_) {
      // History is a convenience; the conversation still works in memory.
    }
  }

  String _goalLabel(WellnessGoal goal, {required bool english}) {
    if (!english) return goal.label;
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
