import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    @Default(ChatMessageType.text) ChatMessageType type,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

enum ChatMessageType { text, suggestion, mealAnalysis, encouragement }
