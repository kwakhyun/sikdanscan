import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/services/meal_image_store.dart';
import 'package:sikdanscan/data/services/supabase_backend_service.dart';

void main() {
  late Directory documents;

  setUp(() async {
    documents = await Directory.systemTemp.createTemp('sikdanscan_docs_');
    MealImageStore.debugSetDocumentsPath(documents.path);
  });

  tearDown(() async {
    MealImageStore.debugSetDocumentsPath(null);
    await documents.delete(recursive: true);
  });

  test('persist stores a relative path that resolves to the copy', () async {
    final source = File('${documents.path}/picked.png')..writeAsBytesSync([1]);

    final stored = await MealImageStore.persist(source.path);

    expect(stored, startsWith('meal_images/meal_'));
    expect(stored, endsWith('.png'));
    expect(MealImageStore.resolveFile(stored)?.existsSync(), isTrue);
  });

  test('legacy absolute paths are relocated to the current container', () {
    final file = File('${documents.path}/meal_images/old.jpg')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1]);
    const legacy =
        '/var/mobile/Containers/Data/Application/OLD-UUID/Documents/meal_images/old.jpg';

    expect(MealImageStore.normalizeForStorage(legacy), 'meal_images/old.jpg');
    expect(MealImageStore.resolvePath(legacy), file.path);
    expect(MealImageStore.resolvePath('meal_images/missing.jpg'), isNull);
  });

  test('remote rows keep relative image paths, portion and local dates', () {
    final record = MealRecord(
      id: 'r1',
      date: DateTime(2026, 3, 1, 8, 15),
      mealType: MealType.breakfast,
      name: '오트밀',
      calories: 300,
      carbs: 50,
      protein: 10,
      fat: 5,
      portion: 1.5,
      imageUrl: '${documents.path}/meal_images/a.jpg',
      imageStoragePath: 'user/r1.jpg',
    );

    final row = SupabaseBackendService.mealRecordToRowForTest('user', record);
    expect(row['image_url'], 'meal_images/a.jpg');
    expect(row['portion'], 1.5);
    expect(row['image_storage_path'], 'user/r1.jpg');

    final restored = SupabaseBackendService.mealRecordFromRowForTest(row);
    expect(restored.date, record.date);
    expect(restored.date.isUtc, isFalse);
    expect(restored.portion, 1.5);
    expect(restored.imageStoragePath, 'user/r1.jpg');
  });
}
