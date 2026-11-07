import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/meal_record.dart';
import '../../data/services/food_api_service.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_svg_icon.dart';

/// Search-based logging (built-in DB, public food DB and AI analysis through
/// the proxy) plus recently logged foods and manual entry. Works offline with
/// the built-in database. Picked foods continue to the review step.
class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({
    super.key,
    this.initialDate,
    this.appendToReview = false,
  });

  /// Day the meal is logged on (defaults to today).
  final DateTime? initialDate;

  /// When opened from the review step, picked foods are appended there.
  final bool appendToReview;

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _searchController = TextEditingController();
  List<FoodItem> _filteredFoods = [];
  final List<FoodItem> _selectedFoods = [];
  bool _isSearching = false;
  bool _isAiAnalyzing = false;
  bool _hasSearchError = false;
  Timer? _debounce;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _filterFoods('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    setState(() {});
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

    setState(() {
      _isSearching = true;
      _isAiAnalyzing = trimmedQuery.isNotEmpty && foodService.isProxyConfigured;
      _hasSearchError = false;
    });

    try {
      final foods = await foodService.searchFood(
        trimmedQuery,
        locale: ref.read(resolvedLanguageCodeProvider),
      );
      if (mounted && requestId == _searchRequestId) {
        setState(() => _filteredFoods = foods);
      }
    } catch (_) {
      if (mounted && requestId == _searchRequestId) {
        setState(() => _hasSearchError = true);
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

  void _toggleFood(FoodItem food) {
    setState(() {
      final index = _selectedFoods.indexWhere((f) => _sameFood(f, food));
      if (index >= 0) {
        _selectedFoods.removeAt(index);
      } else {
        _selectedFoods.add(food);
      }
    });
  }

  bool _isSelected(FoodItem food) =>
      _selectedFoods.any((f) => _sameFood(f, food));

  static bool _sameFood(FoodItem a, FoodItem b) {
    return a.name == b.name && a.calories == b.calories && a.source == b.source;
  }

  int get _totalCalories =>
      _selectedFoods.fold(0, (sum, f) => sum + f.calories);

  void _continue({bool manual = false}) {
    final controller = ref.read(mealCaptureProvider.notifier);
    if (widget.appendToReview) {
      controller.addFoods(List.of(_selectedFoods));
      if (manual) controller.addBlankDraft();
      context.pop();
      return;
    }
    controller.startManual(
      foods: List.of(_selectedFoods),
      date: widget.initialDate,
    );
    if (manual) controller.addBlankDraft();
    context.pushReplacement(AppRoutes.mealReview);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: Text(l10n.addMealTitle),
        leading: IconButton(
          tooltip: l10n.commonClose,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _continue(manual: true),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(l10n.addMealManualEntry),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_isAiAnalyzing) _buildAiAnalyzingBanner(),
          Expanded(child: _buildFoodList()),
        ],
      ),
      bottomNavigationBar: _selectedFoods.isEmpty ? null : _buildSelectionBar(),
    );
  }

  Widget _buildSearchBar() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.addMealSearchHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colorTextTertiary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: l10n.commonClear,
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
              AppSvgIcon(
                'assets/icons/app/hint.svg',
                color: context.colorWarningText,
                size: 14,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  ref.watch(foodApiServiceProvider).isProxyConfigured
                      ? l10n.addMealAiHint
                      : l10n.addMealOfflineHint,
                  style: AppTextStyles.micro.copyWith(
                    color: context.colorTextSecondary,
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colorSecondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.addMealAiAnalyzing,
              style: AppTextStyles.label.copyWith(
                color: context.colorSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    final l10n = context.l10n;
    final locale = context.localeTag;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: context.colorSurface,
          border: Border(top: BorderSide(color: context.colorBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFoods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final food = _selectedFoods[index];
                  return InputChip(
                    label: Text(food.name),
                    onDeleted: () => _toggleFood(food),
                    deleteButtonTooltipMessage: l10n.addMealRemoveTooltip(
                      food.name,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addMealSelectedSummary(
                      _selectedFoods.length,
                      AppFormat.integer(_totalCalories, locale),
                    ),
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: context.colorTextPrimary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                  ),
                  child: Text(l10n.commonNext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    final l10n = context.l10n;
    if (_isSearching && _filteredFoods.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasSearchError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: context.colorErrorText,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addMealSearchError,
              style: AppTextStyles.body.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _filterFoods(_searchController.text),
              child: Text(l10n.addMealRetry),
            ),
          ],
        ),
      );
    }

    final isQuery = _searchController.text.trim().isNotEmpty;
    final recent = isQuery
        ? const <MealRecord>[]
        : ref.watch(recentFoodsProvider);
    final localFoods = _filteredFoods
        .where((f) => f.source == FoodSource.localDb)
        .toList();
    final publicFoods = _filteredFoods
        .where((f) => f.source == FoodSource.publicApi)
        .toList();
    final aiFoods = _filteredFoods
        .where((f) => f.source == FoodSource.aiAnalysis)
        .toList();

    if (isQuery && _filteredFoods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: context.colorTextTertiary,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.addMealNoSearchResults,
                style: AppTextStyles.body.copyWith(
                  color: context.colorTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _continue(manual: true),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.addMealManualEntry),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        if (recent.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.history_rounded,
            title: l10n.addMealRecentTitle,
            count: recent.length,
          ),
          const SizedBox(height: 8),
          ...recent.map((meal) => _buildFoodTile(_foodFromRecord(meal))),
          const SizedBox(height: 16),
        ],
        if (localFoods.isNotEmpty) ...[
          _SectionHeader(
            iconAsset: 'assets/icons/app/source_local_db.svg',
            title: isQuery
                ? l10n.addMealSourceBuiltInDb
                : l10n.addMealSuggestedTitle,
            count: localFoods.length,
          ),
          const SizedBox(height: 8),
          ...localFoods.map(_buildFoodTile),
        ],
        if (publicFoods.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            iconAsset: 'assets/icons/app/source_public_api.svg',
            title: l10n.addMealSourcePublicFoodDb,
            count: publicFoods.length,
            tag: l10n.addMealPublicData,
          ),
          const SizedBox(height: 8),
          ...publicFoods.map(_buildFoodTile),
        ],
        if (aiFoods.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            iconAsset: 'assets/icons/app/source_ai.svg',
            title: l10n.addMealSourceAiResults,
            count: aiFoods.length,
            tag: l10n.addMealAiTag,
          ),
          const SizedBox(height: 8),
          ...aiFoods.map(_buildFoodTile),
        ],
      ],
    );
  }

  /// Re-log a previous record at its 1× base portion.
  FoodItem _foodFromRecord(MealRecord meal) {
    final base = meal.withPortion(1.0);
    return FoodItem(
      name: base.name,
      calories: base.calories,
      carbs: base.carbs,
      protein: base.protein,
      fat: base.fat,
      servingSize: base.servingSize,
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    final l10n = context.l10n;
    final selected = _isSelected(food);
    final macros = l10n.macroShort(
      food.carbs.toStringAsFixed(0),
      food.protein.toStringAsFixed(0),
      food.fat.toStringAsFixed(0),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? context.colorPrimarySurface : context.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? context.colorPrimaryText : context.colorBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => _toggleFood(food),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          title: Text(
            food.name,
            style: AppTextStyles.bodyStrong.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          subtitle: Text(
            [
              macros,
              if (food.servingSize != null) food.servingSize!,
            ].join(' · '),
            style: AppTextStyles.micro.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppFormat.kcal(food.calories, context.localeTag),
                style: AppTextStyles.label.copyWith(
                  color: context.colorTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline,
                color: selected
                    ? context.colorPrimaryText
                    : context.colorTextTertiary,
                semanticLabel: selected
                    ? l10n.addMealRemoveTooltip(food.name)
                    : l10n.addMealAddTooltip(food.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.icon,
    this.iconAsset,
    this.tag,
  });

  final String title;
  final int count;
  final IconData? icon;
  final String? iconAsset;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final color = context.colorTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (iconAsset != null)
            AppSvgIcon(iconAsset!, color: color, size: 16)
          else if (icon != null)
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$title ($count)',
            style: AppTextStyles.label.copyWith(color: color),
          ),
          if (tag != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colorSurfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag!,
                style: AppTextStyles.micro.copyWith(color: color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
