// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  content: json['content'] as String,
  isUser: json['isUser'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type:
      $enumDecodeNullable(_$ChatMessageTypeEnumMap, json['type']) ??
      ChatMessageType.text,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$ChatMessageTypeEnumMap[instance.type]!,
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.suggestion: 'suggestion',
  ChatMessageType.mealAnalysis: 'mealAnalysis',
  ChatMessageType.encouragement: 'encouragement',
};
