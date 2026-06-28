import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/weight_record.dart';
import 'package:sikdanscan/data/models/chat_message.dart';

void main() {
  group('WeightRecord', () {
    test('creates with required fields', () {
      final record = WeightRecord(
        id: 'w_1',
        date: DateTime(2026, 2, 12),
        weight: 68.5,
      );

      expect(record.weight, 68.5);
      expect(record.bodyFat, isNull);
      expect(record.muscleMass, isNull);
    });

    test('copyWith updates weight', () {
      final record = WeightRecord(
        id: 'w_1',
        date: DateTime(2026, 2, 12),
        weight: 68.5,
        bodyFat: 22.0,
      );

      final updated = record.copyWith(weight: 67.8);

      expect(updated.weight, 67.8);
      expect(updated.bodyFat, 22.0);
    });

    test('toJson and fromJson roundtrip', () {
      final record = WeightRecord(
        id: 'w_1',
        date: DateTime(2026, 2, 12),
        weight: 68.5,
        bodyFat: 22.0,
        muscleMass: 27.5,
        memo: '오늘 기분 좋음',
      );

      final json = record.toJson();
      final restored = WeightRecord.fromJson(json);

      expect(restored.id, record.id);
      expect(restored.weight, record.weight);
      expect(restored.bodyFat, record.bodyFat);
      expect(restored.muscleMass, record.muscleMass);
      expect(restored.memo, record.memo);
    });
  });

  group('ChatMessage', () {
    test('creates with default type', () {
      final msg = ChatMessage(
        id: 'c_1',
        content: '안녕하세요',
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(msg.type, ChatMessageType.text);
    });

    test('toJson and fromJson roundtrip', () {
      final msg = ChatMessage(
        id: 'c_1',
        content: '칼로리 분석해줘',
        isUser: true,
        timestamp: DateTime(2026, 2, 12, 14, 30),
        type: ChatMessageType.suggestion,
      );

      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.id, msg.id);
      expect(restored.content, msg.content);
      expect(restored.isUser, msg.isUser);
      expect(restored.type, ChatMessageType.suggestion);
    });

    test('ChatMessageType has all expected values', () {
      expect(ChatMessageType.values.length, 4);
      expect(ChatMessageType.values, contains(ChatMessageType.text));
      expect(ChatMessageType.values, contains(ChatMessageType.suggestion));
      expect(ChatMessageType.values, contains(ChatMessageType.mealAnalysis));
      expect(ChatMessageType.values, contains(ChatMessageType.encouragement));
    });
  });
}
