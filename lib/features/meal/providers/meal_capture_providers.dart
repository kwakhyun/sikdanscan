import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/food_recognition_result.dart';
import '../../../data/models/meal_record.dart';
import '../../../data/services/food_api_service.dart';
import '../../../data/services/food_image_recognition_service.dart';
import '../../../data/services/meal_image_store.dart';
import '../../../providers/service_providers.dart';
import '../../profile/providers/profile_providers.dart';
import 'meal_providers.dart';

/// Editable candidate food in the review step. Nutrition values are for one
/// (1×) portion; [portion] scales them when saved.
class MealDraft {
  const MealDraft({
    required this.key,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.servingSize,
    this.confidence,
    this.source = FoodSource.localDb,
    this.selected = true,
    this.portion = 1.0,
  });

  factory MealDraft.fromFood(FoodItem food, {required String key}) {
    return MealDraft(
      key: key,
      name: food.name,
      calories: food.calories.toDouble(),
      carbs: food.carbs,
      protein: food.protein,
      fat: food.fat,
      servingSize: food.servingSize,
      confidence: food.recognitionConfidence,
      source: food.source,
    );
  }

  factory MealDraft.fromRecognized(
    RecognizedFoodItem item, {
    required String key,
  }) {
    return MealDraft(
      key: key,
      name: item.name,
      calories: item.calories.toDouble(),
      carbs: item.carbs,
      protein: item.protein,
      fat: item.fat,
      servingSize: item.servingSize,
      confidence: item.confidence,
      source: FoodSource.imageRecognition,
    );
  }

  final String key;
  final String name;

  /// 1× calories, kept unrounded so a total typed at another portion
  /// round-trips exactly.
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? servingSize;
  final double? confidence;
  final FoodSource source;
  final bool selected;
  final double portion;

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': name,
    'calories': calories,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
    if (servingSize != null) 'servingSize': servingSize,
    if (confidence != null) 'confidence': confidence,
    'source': source.name,
    'selected': selected,
    'portion': portion,
  };

  static MealDraft? fromJson(Map<String, dynamic> json) {
    final key = json['key'];
    final name = json['name'];
    if (key is! String || name is! String) return null;
    double number(Object? value) => value is num ? value.toDouble() : 0;
    return MealDraft(
      key: key,
      name: name,
      calories: number(json['calories']),
      carbs: number(json['carbs']),
      protein: number(json['protein']),
      fat: number(json['fat']),
      servingSize: json['servingSize'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      source: FoodSource.values.firstWhere(
        (source) => source.name == json['source'],
        orElse: () => FoodSource.localDb,
      ),
      selected: json['selected'] != false,
      portion: number(json['portion']) > 0 ? number(json['portion']) : 1.0,
    );
  }

  bool get isValid => name.trim().isNotEmpty;
  bool get isLowConfidence =>
      source == FoodSource.imageRecognition && (confidence ?? 0) < 0.6;

  int get scaledCalories => (calories * portion).round();
  double get scaledCarbs => carbs * portion;
  double get scaledProtein => protein * portion;
  double get scaledFat => fat * portion;

  MealDraft copyWith({
    String? name,
    double? calories,
    double? carbs,
    double? protein,
    double? fat,
    bool? selected,
    double? portion,
  }) {
    return MealDraft(
      key: key,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      servingSize: servingSize,
      confidence: confidence,
      source: source,
      selected: selected ?? this.selected,
      portion: portion ?? this.portion,
    );
  }
}

enum MealCaptureStatus { idle, analyzing, review, failed }

enum MealCaptureError {
  none,
  proxyRequired,
  consentRequired,
  noFoodFound,
  recognitionFailed,
}

class MealCaptureState {
  const MealCaptureState({
    this.status = MealCaptureStatus.idle,
    this.imagePath,
    this.drafts = const [],
    this.summary,
    this.warning,
    this.confidence,
    this.needsReview = false,
    this.error = MealCaptureError.none,
    this.errorMessage,
    this.saving = false,
    required this.mealType,
    required this.dateTime,
  });

  factory MealCaptureState.initial({DateTime? at}) {
    final time = at ?? DateTime.now();
    return MealCaptureState(mealType: MealType.fromTime(time), dateTime: time);
  }

  final MealCaptureStatus status;

  /// Stored (relative) photo path, when the entry started from a photo.
  final String? imagePath;
  final List<MealDraft> drafts;
  final String? summary;
  final String? warning;
  final double? confidence;
  final bool needsReview;
  final MealCaptureError error;

  /// Server/service supplied message (already localized).
  final String? errorMessage;
  final MealType mealType;
  final DateTime dateTime;

  /// True while [MealCaptureController.save] runs; leaving is ignored then.
  final bool saving;

  List<MealDraft> get selectedDrafts =>
      drafts.where((draft) => draft.selected && draft.isValid).toList();

  bool get canSave =>
      status == MealCaptureStatus.review &&
      !saving &&
      selectedDrafts.isNotEmpty;

  int get selectedCalories =>
      selectedDrafts.fold(0, (sum, draft) => sum + draft.scaledCalories);

  bool get hasUnsavedWork =>
      status == MealCaptureStatus.analyzing || drafts.isNotEmpty;

  MealCaptureState copyWith({
    MealCaptureStatus? status,
    String? imagePath,
    bool clearImage = false,
    List<MealDraft>? drafts,
    String? summary,
    String? warning,
    double? confidence,
    bool? needsReview,
    MealCaptureError? error,
    String? errorMessage,
    bool clearError = false,
    MealType? mealType,
    DateTime? dateTime,
    bool? saving,
  }) {
    return MealCaptureState(
      status: status ?? this.status,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      drafts: drafts ?? this.drafts,
      summary: summary ?? this.summary,
      warning: warning ?? this.warning,
      confidence: confidence ?? this.confidence,
      needsReview: needsReview ?? this.needsReview,
      error: clearError ? MealCaptureError.none : (error ?? this.error),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mealType: mealType ?? this.mealType,
      dateTime: dateTime ?? this.dateTime,
      saving: saving ?? this.saving,
    );
  }
}

/// Owns the photo-recognition → review → save flow outside the widget tree,
/// so leaving a screen never drops a finished (and billed) analysis.
final mealCaptureProvider =
    StateNotifierProvider<MealCaptureController, MealCaptureState>((ref) {
      return MealCaptureController(ref);
    });

class MealCaptureController extends StateNotifier<MealCaptureState> {
  MealCaptureController(this._ref) : super(_restore(_ref));

  /// Brings back an unfinished review after the app was closed or killed by
  /// the system (e.g. while the camera app was open), so a finished, billed
  /// analysis and the stored photo are not lost. An analysis that was still
  /// running is offered again as a retry.
  static MealCaptureState _restore(Ref ref) {
    try {
      final json = ref.read(localStorageServiceProvider).getCaptureDraft();
      if (json == null) return MealCaptureState.initial();
      final status = MealCaptureStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => MealCaptureStatus.idle,
      );
      final drafts = [
        for (final raw in (json['drafts'] as List? ?? const []))
          if (raw is Map) MealDraft.fromJson(Map<String, dynamic>.from(raw)),
      ].whereType<MealDraft>().toList();
      final imagePath = json['imagePath'] as String?;
      final dateTime =
          DateTime.tryParse(json['dateTime'] as String? ?? '')?.toLocal() ??
          DateTime.now();
      if (status == MealCaptureStatus.idle ||
          (drafts.isEmpty && imagePath == null)) {
        return MealCaptureState.initial();
      }
      final interrupted = status == MealCaptureStatus.analyzing;
      return MealCaptureState(
        status: interrupted ? MealCaptureStatus.failed : status,
        imagePath: imagePath,
        drafts: drafts,
        summary: json['summary'] as String?,
        warning: json['warning'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        needsReview: json['needsReview'] == true,
        error: interrupted
            ? MealCaptureError.recognitionFailed
            : MealCaptureError.values.firstWhere(
                (value) => value.name == json['error'],
                orElse: () => MealCaptureError.none,
              ),
        mealType: MealType.values.firstWhere(
          (value) => value.name == json['mealType'],
          orElse: () => MealType.fromTime(dateTime),
        ),
        dateTime: dateTime,
      );
    } catch (_) {
      return MealCaptureState.initial();
    }
  }

  @override
  set state(MealCaptureState value) {
    super.state = value;
    _persist(value);
  }

  void _persist(MealCaptureState value) {
    final storage = _ref.read(localStorageServiceProvider);
    final worthKeeping =
        value.status != MealCaptureStatus.idle &&
        !value.saving &&
        (value.drafts.isNotEmpty || value.imagePath != null);
    try {
      unawaited(
        (worthKeeping
                ? storage.saveCaptureDraft({
                    'status': value.status.name,
                    'imagePath': value.imagePath,
                    'drafts': [
                      for (final draft in value.drafts) draft.toJson(),
                    ],
                    'summary': value.summary,
                    'warning': value.warning,
                    'confidence': value.confidence,
                    'needsReview': value.needsReview,
                    'error': value.error.name,
                    'mealType': value.mealType.name,
                    'dateTime': value.dateTime.toUtc().toIso8601String(),
                  })
                : storage.clearCaptureDraft())
            .catchError((Object _) {}),
      );
    } catch (_) {
      // Storage unavailable (tests): the flow works in memory.
    }
  }

  static const _uuid = Uuid();

  final Ref _ref;
  CancelToken? _cancelToken;
  int _generation = 0;

  bool get isRecognitionAvailable =>
      _ref.read(foodImageRecognitionServiceProvider).isConfigured;

  /// Default timestamp for a new entry on [date]: now for today, otherwise
  /// the current clock time on that day.
  static DateTime defaultDateTime(DateTime? date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (date == null) return current;
    return DateTime(
      date.year,
      date.month,
      date.day,
      current.hour,
      current.minute,
    );
  }

  /// Starts a review from foods chosen in search / recent foods.
  void startManual({List<FoodItem> foods = const [], DateTime? date}) {
    _cancelInFlight();
    final at = defaultDateTime(date);
    state = MealCaptureState.initial(at: at).copyWith(
      status: MealCaptureStatus.review,
      drafts: [
        for (final food in foods) MealDraft.fromFood(food, key: _uuid.v4()),
      ],
    );
  }

  /// Adds foods to the current review (e.g. "search and add" from review).
  void addFoods(List<FoodItem> foods) {
    if (foods.isEmpty) return;
    state = state.copyWith(
      status: MealCaptureStatus.review,
      drafts: [
        ...state.drafts,
        for (final food in foods) MealDraft.fromFood(food, key: _uuid.v4()),
      ],
      clearError: true,
    );
  }

  /// Adds an empty row the user fills in by hand.
  String addBlankDraft() {
    final key = _uuid.v4();
    state = state.copyWith(
      status: MealCaptureStatus.review,
      drafts: [
        ...state.drafts,
        MealDraft(
          key: key,
          name: '',
          calories: 0,
          carbs: 0,
          protein: 0,
          fat: 0,
        ),
      ],
      clearError: true,
    );
    return key;
  }

  Future<void> startFromImage(String storedImagePath, {DateTime? date}) async {
    _cancelInFlight();
    final generation = ++_generation;
    final token = CancelToken();
    _cancelToken = token;
    final at = defaultDateTime(date);

    state = MealCaptureState.initial(
      at: at,
    ).copyWith(status: MealCaptureStatus.analyzing, imagePath: storedImagePath);

    final service = _ref.read(foodImageRecognitionServiceProvider);
    if (!service.isConfigured) {
      state = state.copyWith(
        status: MealCaptureStatus.failed,
        error: MealCaptureError.proxyRequired,
      );
      return;
    }
    if (!_ref.read(aiDataConsentProvider)) {
      state = state.copyWith(
        status: MealCaptureStatus.failed,
        error: MealCaptureError.consentRequired,
      );
      return;
    }

    try {
      final absolute =
          MealImageStore.resolvePath(storedImagePath) ?? storedImagePath;
      final result = await service.recognizeImageFile(
        absolute,
        locale: _ref.read(resolvedLanguageCodeProvider),
        cancelToken: token,
      );
      if (!mounted || generation != _generation) return;

      final drafts = [
        for (final item in result.items)
          MealDraft.fromRecognized(item, key: _uuid.v4()),
      ];
      if (drafts.isEmpty) {
        state = state.copyWith(
          status: MealCaptureStatus.failed,
          error: MealCaptureError.noFoodFound,
          errorMessage: result.warning,
        );
        return;
      }

      state = state.copyWith(
        status: MealCaptureStatus.review,
        drafts: drafts,
        summary: result.summary,
        warning: result.warning,
        confidence: result.confidence,
        needsReview: result.needsReview,
        clearError: true,
      );
    } on FoodImageRecognitionCancelled {
      return;
    } on FoodImageRecognitionException catch (error) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
        status: MealCaptureStatus.failed,
        error: MealCaptureError.recognitionFailed,
        errorMessage: error.message,
      );
    } catch (_) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
        status: MealCaptureStatus.failed,
        error: MealCaptureError.recognitionFailed,
      );
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
    }
  }

  Future<void> retryRecognition() async {
    final imagePath = state.imagePath;
    if (imagePath == null) return;
    await startFromImage(imagePath, date: state.dateTime);
  }

  /// Stops analysis and continues with manual entry, keeping the photo.
  /// [addBlank] adds an empty row to type into (skipped when the user goes
  /// to search instead).
  void switchToManual({bool addBlank = true}) {
    _cancelInFlight();
    state = state.copyWith(status: MealCaptureStatus.review, clearError: true);
    if (addBlank && state.drafts.isEmpty) addBlankDraft();
  }

  void updateDraft(String key, MealDraft Function(MealDraft draft) update) {
    state = state.copyWith(
      drafts: [
        for (final draft in state.drafts)
          if (draft.key == key) update(draft) else draft,
      ],
    );
  }

  void removeDraft(String key) {
    state = state.copyWith(
      drafts: state.drafts.where((draft) => draft.key != key).toList(),
    );
  }

  void setMealType(MealType type) => state = state.copyWith(mealType: type);

  void setDateTime(DateTime dateTime) {
    state = state.copyWith(dateTime: dateTime);
  }

  /// Saves the selected drafts as meal records and resets the flow.
  ///
  /// Every record is built from one snapshot of the review (time, meal type,
  /// photo) and written locally in a single step; uploading happens in the
  /// background, so this returns almost immediately.
  Future<int> save() async {
    if (!state.canSave) return 0;
    final snapshot = state;
    final drafts = snapshot.selectedDrafts;
    final records = [
      for (final draft in drafts)
        MealRecord(
          id: _uuid.v4(),
          date: snapshot.dateTime,
          mealType: snapshot.mealType,
          name: draft.name.trim(),
          calories: draft.scaledCalories,
          carbs: draft.scaledCarbs,
          protein: draft.scaledProtein,
          fat: draft.scaledFat,
          portion: draft.portion,
          servingSize: draft.servingSize,
          imageUrl: snapshot.imagePath,
          isAiRecognized: draft.source == FoodSource.imageRecognition,
          recognitionConfidence: draft.source == FoodSource.imageRecognition
              ? draft.confidence
              : null,
        ),
    ];

    state = snapshot.copyWith(saving: true);
    try {
      await _ref.read(mealRecordsProvider.notifier).addMeals(records);
    } catch (_) {
      if (mounted) state = state.copyWith(saving: false);
      rethrow;
    }
    if (mounted) reset(deleteUnusedImage: false);
    return drafts.length;
  }

  /// Discards the flow. The photo is deleted unless a saved record uses it.
  void reset({bool deleteUnusedImage = true}) {
    final imagePath = state.imagePath;
    _cancelInFlight();
    state = MealCaptureState.initial();
    if (deleteUnusedImage && imagePath != null) {
      _ref.read(mealRecordsProvider.notifier).purgeOrphanImage(imagePath);
    }
  }

  void _cancelInFlight() {
    _generation++;
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  @override
  void dispose() {
    _cancelInFlight();
    super.dispose();
  }
}
