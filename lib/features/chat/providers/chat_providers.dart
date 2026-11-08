import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/ai_chat_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';
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

/// Whether the consent sheet was already offered automatically in this
/// session; after "Not now" the coach keeps answering with tips and the
/// banner's button is the way to opt in.
final aiConsentAutoPromptedProvider = StateProvider<bool>((ref) => false);

/// Coach reachability, from the outcome of requests made in this session.
enum CoachConnection { unknown, online, offline, limited, error, needsConsent }

/// Last request outcome in this app session. Not persisted: an offline answer
/// saved days ago says nothing about the connection now.
final coachConnectionProvider = StateProvider<CoachConnection>((ref) {
  // Starts over when consent changes: answers given without consent were
  // local tips and say nothing about the server.
  ref.watch(aiDataConsentProvider);
  return CoachConnection.unknown;
});

/// What the chat header shows: offline when no AI server is configured,
/// otherwise the latest outcome (online until something fails).
final chatStatusProvider = Provider<CoachConnection>((ref) {
  if (!ref.watch(aiChatServiceProvider).isConfigured) {
    return CoachConnection.offline;
  }
  if (!ref.watch(aiDataConsentProvider)) return CoachConnection.needsConsent;
  final connection = ref.watch(coachConnectionProvider);
  return connection == CoachConnection.unknown
      ? CoachConnection.online
      : connection;
});

/// Whether answers currently come from the AI server.
final chatOnlineProvider = Provider<bool>((ref) {
  return ref.watch(chatStatusProvider) == CoachConnection.online;
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier(this._ref, this._storage) : super(_load(_storage));

  static const maxStoredMessages = 80;
  static const _uuid = Uuid();

  final Ref _ref;
  final LocalStorageService _storage;

  /// Bumped by [clear] and [dispose]; a reply that arrives for an older
  /// conversation is dropped instead of being appended and saved.
  int _generation = 0;

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
    _generation++;
    _setLoading(false);
    state = const [];
    await _persist();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  Future<void> _requestReply(String userMessage) async {
    final generation = _generation;
    _setLoading(true);
    try {
      final service = _ref.read(aiChatServiceProvider);
      final locale = _ref.read(resolvedLanguageCodeProvider);
      // Nothing personal leaves the device without consent.
      final allowed = _ref.read(aiDataConsentProvider);
      final reply = allowed
          ? await service.reply(
              userMessage: userMessage,
              history: _historyBefore(userMessage),
              context: buildCoachContext(),
              locale: locale,
            )
          : AiChatReply(
              content: service.fallbackResponse(userMessage, locale: locale),
              isFallback: true,
            );
      if (!mounted || generation != _generation) return;
      if (allowed) {
        _setConnection(
          !reply.isFallback
              ? CoachConnection.online
              : reply.quotaExceeded
              ? CoachConnection.limited
              : CoachConnection.offline,
        );
      }
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
      if (!mounted || generation != _generation) return;
      _setConnection(CoachConnection.error);
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
      // A newer conversation (after clear) manages its own loading state.
      // Reset and account switches re-create chatLoadingProvider itself.
      if (generation == _generation) _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    try {
      _ref.read(chatLoadingProvider.notifier).state = value;
    } catch (_) {
      // The provider scope is gone (app teardown).
    }
  }

  void _setConnection(CoachConnection value) {
    try {
      _ref.read(coachConnectionProvider.notifier).state = value;
    } catch (_) {}
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
    final l10n = lookupAppLocalizations(
      Locale(_ref.read(resolvedLanguageCodeProvider)),
    );

    return {
      'todayCalories': _ref.read(todayCaloriesProvider),
      'calorieGoal': profile.dailyCalorieGoal,
      'currentWeight': weight,
      'targetWeight': profile.targetWeight,
      'wellnessGoal': profile.wellnessGoal.labelOf(l10n),
      'wellnessGoalDescription': profile.wellnessGoal.descriptionOf(l10n),
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
}
