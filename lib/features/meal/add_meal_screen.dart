import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/food_recognition_result.dart';
import '../../data/models/meal_record.dart';
import '../../data/services/food_api_service.dart';
import '../../data/services/food_image_recognition_service.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_svg_icon.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key, this.openCameraOnStart = false});

  final bool openCameraOnStart;

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _imagePicker = ImagePicker();
  final _searchController = TextEditingController();
  List<FoodItem> _filteredFoods = [];
  final List<FoodItem> _selectedFoods = [];
  bool _isSearching = false;
  bool _isAiAnalyzing = false;
  bool _isRecognizingImage = false;
  String? _searchError;
  String? _recognizedImagePath;
  String? _recognitionSummary;
  String? _recognitionWarning;
  double? _recognitionConfidence;
  MealType? _selectedMealType;
  Timer? _debounce;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialFoods();
    if (widget.openCameraOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _recognizeMealImage(ImageSource.camera);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialFoods() async {
    await _filterFoods('');
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _filterFoods('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterFoods(query);
    });
  }

  Future<void> _filterFoods(String query) async {
    final requestId = ++_searchRequestId;
    final trimmedQuery = query.trim();
    final foodService = ref.read(foodApiServiceProvider);
    final proxyConfigured = foodService.isProxyConfigured;

    setState(() {
      _isSearching = true;
      _isAiAnalyzing = trimmedQuery.isNotEmpty && proxyConfigured;
      _searchError = null;
    });

    try {
      final foods = await foodService.searchFood(
        trimmedQuery,
        locale: ref.read(languageProvider).languageCode,
      );

      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _filteredFoods = foods;
          _isAiAnalyzing = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _searchError = context.l10n.addMealSearchError;
        });
      }
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _isSearching = false;
          _isAiAnalyzing = false;
        });
      }
    }
  }

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food);
    });
  }

  void _removeFood(int index) {
    setState(() {
      _selectedFoods.removeAt(index);
    });
  }

  Future<void> _recognizeMealImage(ImageSource source) async {
    final service = ref.read(foodImageRecognitionServiceProvider);
    if (!service.isConfigured) {
      _showMessage(context.l10n.dashboardProxyRequired);
      return;
    }

    final picked = await _pickMealImage(source);
    if (picked == null) return;

    setState(() {
      _isRecognizingImage = true;
      _recognizedImagePath = picked.path;
      _recognitionSummary = null;
      _recognitionWarning = null;
      _recognitionConfidence = null;
      _searchError = null;
    });

    try {
      final persistedImagePath = await _persistMealImage(picked);
      if (mounted && persistedImagePath != _recognizedImagePath) {
        setState(() => _recognizedImagePath = persistedImagePath);
      }

      final result = await service.recognizeImageFile(
        persistedImagePath,
        locale: ref.read(languageProvider).languageCode,
      );
      final foods = result.items
          .map(
            (item) =>
                _recognizedItemToFood(item, imagePath: persistedImagePath),
          )
          .toList();

      if (!mounted) return;
      if (foods.isEmpty) {
        _clearRecognitionResult();
        _showMessage(
          result.warning?.isNotEmpty == true
              ? result.warning!
              : context.l10n.dashboardNoFoodFound,
        );
        return;
      }

      setState(() {
        _selectedFoods.addAll(foods);
        _recognitionSummary = result.summary;
        _recognitionWarning = result.warning;
        _recognitionConfidence = result.confidence;
      });

      if (result.needsReview) {
        _showMessage(context.l10n.addMealRecognitionAdded);
      } else {
        _showMessage(context.l10n.addMealRecognizedCount(foods.length));
      }
    } on FoodImageRecognitionException catch (e) {
      if (!mounted) return;
      _clearRecognitionResult();
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _clearRecognitionResult();
      _showMessage(context.l10n.dashboardRecognitionError);
    } finally {
      if (mounted) {
        setState(() => _isRecognizingImage = false);
      }
    }
  }

  Future<XFile?> _pickMealImage(ImageSource source) async {
    final effectiveSource = _effectiveImageSource(source);
    if (effectiveSource != source) {
      _showMessage(context.l10n.dashboardCameraFallback);
    }

    try {
      return await _pickImage(effectiveSource);
    } on PlatformException {
      if (source == ImageSource.camera &&
          effectiveSource != ImageSource.gallery &&
          _imagePicker.supportsImageSource(ImageSource.gallery)) {
        _showMessage(context.l10n.dashboardCameraFallback);
        try {
          return await _pickImage(ImageSource.gallery);
        } on PlatformException {
          // Fall through to the generic permission/source message below.
        }
      }

      _showMessage(context.l10n.dashboardPhotoPermissionError);
      return null;
    }
  }

  ImageSource _effectiveImageSource(ImageSource source) {
    if (source == ImageSource.camera &&
        !_imagePicker.supportsImageSource(ImageSource.camera) &&
        _imagePicker.supportsImageSource(ImageSource.gallery)) {
      return ImageSource.gallery;
    }
    return source;
  }

  Future<XFile?> _pickImage(ImageSource source) {
    return _imagePicker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 82,
    );
  }

  void _clearRecognitionResult() {
    setState(() {
      _recognizedImagePath = null;
      _recognitionSummary = null;
      _recognitionWarning = null;
      _recognitionConfidence = null;
    });
  }

  Future<String> _persistMealImage(XFile picked) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDirectory = Directory('${directory.path}/meal_images');
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }

      final extension = _imageExtension(picked.path);
      final fileName = 'meal_${const Uuid().v4()}$extension';
      final targetPath = '${imageDirectory.path}/$fileName';
      await File(picked.path).copy(targetPath);
      return targetPath;
    } catch (_) {
      return picked.path;
    }
  }

  String _imageExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.heic')) return '.heic';
    return '.jpg';
  }

  FoodItem _recognizedItemToFood(
    RecognizedFoodItem item, {
    required String imagePath,
  }) {
    return FoodItem(
      name: item.name,
      calories: item.calories,
      carbs: item.carbs,
      protein: item.protein,
      fat: item.fat,
      servingSize: item.servingSize,
      imageUrl: imagePath,
      recognitionConfidence: item.confidence,
      isAiGenerated: true,
      source: FoodSource.imageRecognition,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _saveMeal() async {
    const uuid = Uuid();
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();

    final mealType = _selectedMealType ?? MealType.fromTime(now);
    final notifier = ref.read(mealRecordsProvider.notifier);
    for (final food in _selectedFoods) {
      await notifier.addMeal(
        food.toMealRecord(
          id: uuid.v4(),
          date: DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            now.hour,
            now.minute,
          ),
          mealType: mealType,
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  int get _totalCalories =>
      _selectedFoods.fold(0, (sum, f) => sum + f.calories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: Text(
          context.l10n.addMealTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedFoods.isNotEmpty)
            TextButton(
              onPressed: _saveMeal,
              child: Text(
                context.l10n.commonSave,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPhotoRecognitionPanel(),
          if (_recognizedImagePath != null || _recognitionSummary != null)
            _buildRecognitionResultPanel(),
          _buildSearchBar(),
          if (_isAiAnalyzing) _buildAiAnalyzingBanner(),
          if (_selectedFoods.isNotEmpty) _buildSelectedFoods(),
          Expanded(child: _buildFoodList()),
        ],
      ),
    );
  }

  Widget _buildPhotoRecognitionPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.addMealRecognitionTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.addMealRecognitionSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: context.l10n.dashboardPickPhoto,
            onPressed: _isRecognizingImage
                ? null
                : () => _recognizeMealImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded, size: 20),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            tooltip: context.l10n.dashboardCaptureNow,
            onPressed: _isRecognizingImage
                ? null
                : () => _recognizeMealImage(ImageSource.camera),
            icon: _isRecognizingImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_alt_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionResultPanel() {
    final confidence = _recognitionConfidence;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recognizedImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_recognizedImagePath!),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colorSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_search_rounded),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _recognitionSummary?.isNotEmpty == true
                            ? _recognitionSummary!
                            : _isRecognizingImage
                            ? context.l10n.addMealAnalyzingPhoto
                            : context.l10n.addMealRecognitionResult,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                    if (confidence != null)
                      Text(
                        '${(confidence * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                if (_recognitionWarning?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    _recognitionWarning!,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: context.l10n.addMealSearchHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colorTextTertiary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const AppSvgIcon(
                'assets/icons/app/hint.svg',
                color: AppColors.warning,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  context.l10n.addMealAiHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colorTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalyzingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.addMealAiAnalyzing,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoods() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorPrimarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.l10n.addMealSelectedFoods} (${_selectedFoods.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${_totalCalories}kcal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: context.colorTextSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.l10n.mealDetailMealType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: MealType.values.map((type) {
                  final selected =
                      type ==
                      (_selectedMealType ?? MealType.fromTime(DateTime.now()));
                  return ChoiceChip(
                    label: Text(type.labelOf(context.l10n)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedMealType = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : context.colorTextSecondary,
                    ),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : context.colorBorder,
                      ),
                    ),
                    backgroundColor: context.colorSurface,
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFoods.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(
                      entry.value.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    avatar: entry.value.source == FoodSource.imageRecognition
                        ? const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: AppColors.primary,
                          )
                        : entry.value.isAiGenerated
                        ? const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.secondary,
                          )
                        : null,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFood(entry.key),
                    backgroundColor: context.colorSurface,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFoodList() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _searchError!,
              style: TextStyle(color: context.colorTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _filterFoods(_searchController.text),
              child: Text(context.l10n.addMealRetry),
            ),
          ],
        ),
      );
    }

    if (_filteredFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: context.colorTextTertiary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.addMealNoSearchResults,
              style: TextStyle(color: context.colorTextSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final localFoods = _filteredFoods
        .where((f) => f.source == FoodSource.localDb)
        .toList();
    final publicFoods = _filteredFoods
        .where((f) => f.source == FoodSource.publicApi)
        .toList();
    final aiFoods = _filteredFoods
        .where((f) => f.source == FoodSource.aiAnalysis)
        .toList();

    final isSearching = _searchController.text.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (isSearching) ...[
          if (localFoods.isNotEmpty) ...[
            _buildSectionHeader(
              icon: Icons.restaurant_menu_rounded,
              title: context.l10n.addMealSourceBuiltInDb,
              count: localFoods.length,
              iconAsset: 'assets/icons/app/source_local_db.svg',
            ),
            const SizedBox(height: 8),
            ...localFoods.map((food) => _buildFoodTile(food)),
          ],
          if (publicFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              icon: Icons.account_balance_rounded,
              title: context.l10n.addMealSourcePublicFoodDb,
              count: publicFoods.length,
              iconAsset: 'assets/icons/app/source_public_api.svg',
              tagText: context.l10n.addMealPublicData,
              tagColor: Colors.teal,
            ),
            const SizedBox(height: 8),
            ...publicFoods.map((food) => _buildFoodTile(food)),
          ],
          if (aiFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              icon: Icons.auto_awesome,
              title: context.l10n.addMealSourceAiResults,
              count: aiFoods.length,
              iconAsset: 'assets/icons/app/source_ai.svg',
              isAi: true,
            ),
            const SizedBox(height: 8),
            ...aiFoods.map((food) => _buildFoodTile(food)),
          ],
        ] else ...[
          ...localFoods.map((food) => _buildFoodTile(food)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
    String? iconAsset,
    String? tagText,
    Color? tagColor,
    bool isAi = false,
  }) {
    final effectiveColor =
        tagColor ?? (isAi ? AppColors.secondary : context.colorTextTertiary);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            AppSvgIcon(iconAsset, color: effectiveColor, size: 16),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 16, color: effectiveColor),
            const SizedBox(width: 6),
          ],
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isAi ? AppColors.secondary : context.colorTextSecondary,
            ),
          ),
          if (isAi || tagText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tagText ?? context.l10n.addMealAiTag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    final isExternal =
        food.source == FoodSource.aiAnalysis ||
        food.source == FoodSource.publicApi;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: food.source == FoodSource.aiAnalysis
              ? AppColors.secondary.withValues(alpha: 0.3)
              : food.source == FoodSource.publicApi
              ? Colors.teal.withValues(alpha: 0.3)
              : context.colorBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: isExternal
            ? Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AppSvgIcon(
                    food.sourceIconAsset,
                    color: food.source == FoodSource.aiAnalysis
                        ? AppColors.secondary
                        : Colors.teal,
                    size: 18,
                  ),
                ),
              )
            : null,
        title: Text(
          food.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'C ${food.carbs.toStringAsFixed(0)}g · P ${food.protein.toStringAsFixed(0)}g · F ${food.fat.toStringAsFixed(0)}g'
                    : '탄 ${food.carbs.toStringAsFixed(0)}g · 단 ${food.protein.toStringAsFixed(0)}g · 지 ${food.fat.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colorTextTertiary,
                ),
              ),
            ),
            if (food.servingSize != null) ...[
              const SizedBox(width: 6),
              Text(
                food.servingSize!,
                style: TextStyle(
                  fontSize: 10,
                  color: context.colorTextTertiary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${food.calories}kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _addFood(food),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : food.source == FoodSource.publicApi
                      ? Colors.teal.withValues(alpha: 0.1)
                      : context.colorPrimarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: food.source == FoodSource.aiAnalysis
                      ? AppColors.secondary
                      : food.source == FoodSource.publicApi
                      ? Colors.teal
                      : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
