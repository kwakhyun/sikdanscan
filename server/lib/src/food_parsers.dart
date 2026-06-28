import 'dart:convert';

import 'json_helpers.dart';

List<Map<String, dynamic>> parsePublicFoodItems(Map<String, dynamic> data) {
  final header = asStringMap(data['header']);
  final resultCode = header?['resultCode']?.toString();
  if (header == null || (resultCode != '00' && resultCode != '0')) {
    return const [];
  }

  final body = asStringMap(data['body']);
  final itemsContainer = asStringMap(body?['items']);
  final items = asList(itemsContainer?['item'] ?? body?['items']);
  if (items == null) return const [];

  return items
      .map(asStringMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final name = readString(item['FOOD_NM_KR']) ?? '';
        return {
          'name': cleanFoodName(name),
          'calories': readNumeric(item['AMT_NUM1']).round(),
          'carbs': readNumeric(item['AMT_NUM6']),
          'protein': readNumeric(item['AMT_NUM3']),
          'fat': readNumeric(item['AMT_NUM4']),
          'servingSize': readString(item['SERVING_SIZE']) ?? '100g',
          'source': 'publicApi',
          'isAiGenerated': false,
        };
      })
      .where(
        (item) =>
            (item['name'] as String).isNotEmpty &&
            (item['calories'] as int) > 0,
      )
      .toList();
}

List<Map<String, dynamic>> parseAiFoodItems(String content) {
  try {
    final cleaned = cleanModelJson(content);

    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start == -1 || end == -1 || end < start) return const [];

    final decoded = jsonDecode(cleaned.substring(start, end + 1));
    final items = asList(decoded);
    if (items == null) return const [];

    return items
        .map(asStringMap)
        .whereType<Map<String, dynamic>>()
        .map((item) {
          return {
            'name': readString(item['name']) ?? '',
            'calories': readNumeric(item['calories']).round(),
            'carbs': readNumeric(item['carbs']),
            'protein': readNumeric(item['protein']),
            'fat': readNumeric(item['fat']),
            'servingSize': readString(item['servingSize']),
            'source': 'aiAnalysis',
            'isAiGenerated': true,
          };
        })
        .where(
          (item) =>
              (item['name'] as String).isNotEmpty &&
              (item['calories'] as int) > 0,
        )
        .toList();
  } catch (_) {
    return const [];
  }
}

Map<String, dynamic> parseAiFoodRecognition(String content) {
  try {
    final cleaned = cleanModelJson(content);
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) {
      return _emptyRecognition(needsReview: true);
    }

    final decoded = jsonDecode(cleaned.substring(start, end + 1));
    final map = asStringMap(decoded);
    if (map == null) return _emptyRecognition(needsReview: true);

    final items = asList(map['items'])
        ?.map(asStringMap)
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final confidence = readNumeric(
            item['confidence'],
          ).clamp(0.0, 1.0).toDouble();
          return {
            'name': readString(item['name']) ?? '',
            'calories': readNumeric(item['calories']).round(),
            'carbs': readNumeric(item['carbs']),
            'protein': readNumeric(item['protein']),
            'fat': readNumeric(item['fat']),
            'servingSize': readString(item['servingSize']),
            'confidence': confidence,
          };
        })
        .where(
          (item) =>
              (item['name'] as String).isNotEmpty &&
              (item['calories'] as int) > 0,
        )
        .toList();

    final confidence = readNumeric(
      map['confidence'],
    ).clamp(0.0, 1.0).toDouble();
    final needsReview =
        map['needsReview'] == true ||
        confidence < 0.72 ||
        (items ?? []).isEmpty;

    return {
      'summary': readString(map['summary']) ?? '',
      'confidence': confidence,
      'needsReview': needsReview,
      'warning': readString(map['warning']),
      'items': items ?? const [],
    };
  } catch (_) {
    return _emptyRecognition(needsReview: true);
  }
}

String cleanModelJson(String content) {
  var cleaned = content.trim();
  if (cleaned.contains('```')) {
    cleaned = cleaned
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '');
  }
  return cleaned;
}

Map<String, dynamic> _emptyRecognition({required bool needsReview}) {
  return {
    'summary': '',
    'confidence': 0.0,
    'needsReview': needsReview,
    'warning': '음식을 안정적으로 인식하지 못했습니다. 다시 촬영하거나 직접 검색해 주세요.',
    'items': const [],
  };
}

String cleanFoodName(String name) {
  final trimmed = name.trim();
  if (trimmed.length > 30) {
    return '${trimmed.substring(0, 27)}...';
  }
  return trimmed;
}
