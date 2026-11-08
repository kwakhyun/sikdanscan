import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/meal_record.dart';
import '../../data/services/food_api_service.dart';
import '../../data/services/meal_image_store.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';

/// Confirms what will be saved: shows the photo analysis progress, then
/// editable food rows (name, nutrition, portion), meal type and time.
/// Nothing is written to the log until the user taps save.
class MealReviewScreen extends ConsumerStatefulWidget {
  const MealReviewScreen({super.key});

  static const portionOptions = [0.5, 1.0, 1.5, 2.0];

  @override
  ConsumerState<MealReviewScreen> createState() => _MealReviewScreenState();

  /// Asks before discarding unsaved work, then leaves the review.
  ///
  /// The router and controller are captured up front because the widget
  /// that asked (e.g. the analyzing view) can be replaced while the dialog
  /// is open, when the analysis finishes.
  static Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(mealCaptureProvider.notifier);
    final router = GoRouter.of(context);
    final state = ref.read(mealCaptureProvider);
    if (state.saving) return;
    if (state.hasUnsavedWork) {
      final l10n = context.l10n;
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.reviewLeaveTitle),
          content: Text(l10n.reviewLeaveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.reviewLeaveStay),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: dialogContext.colorErrorText,
              ),
              child: Text(l10n.reviewLeaveConfirm),
            ),
          ],
        ),
      );
      if (leave != true || !controller.mounted) return;
    }
    controller.reset();
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.dashboard);
    }
  }
}

class _MealReviewScreenState extends ConsumerState<MealReviewScreen> {
  late final MealCaptureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(mealCaptureProvider.notifier);
  }

  @override
  void dispose() {
    // Leaving by any route (system back from an error, a deep link) ends the
    // flow and deletes a photo no saved record uses. Saved or confirmed
    // exits already reset, so this is a no-op for them.
    final controller = _controller;
    Future.microtask(() {
      if (controller.mounted) controller.reset();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealCaptureProvider);
    final l10n = context.l10n;

    final title = switch (state.status) {
      MealCaptureStatus.analyzing => l10n.reviewAnalyzingTitle,
      MealCaptureStatus.failed => l10n.reviewFailedTitle,
      _ => l10n.reviewTitle,
    };
    void leave() => MealReviewScreen._confirmLeave(context, ref);

    return PopScope(
      canPop: !state.hasUnsavedWork && !state.saving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || ref.read(mealCaptureProvider).saving) return;
        leave();
      },
      child: Scaffold(
        backgroundColor: context.colorBackground,
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            tooltip: l10n.commonClose,
            icon: const Icon(Icons.close_rounded),
            onPressed: state.saving ? null : leave,
          ),
        ),
        body: switch (state.status) {
          MealCaptureStatus.analyzing => _AnalyzingView(
            state: state,
            onCancel: leave,
          ),
          MealCaptureStatus.failed => _FailedView(state: state),
          _ => _ReviewView(state: state),
        },
        bottomNavigationBar: state.status == MealCaptureStatus.review
            ? _SaveBar(state: state)
            : null,
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.imagePath, this.height = 220});

  final String? imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    final file = MealImageStore.resolveFile(imagePath);
    if (file == null) return const SizedBox.shrink();
    return Semantics(
      image: true,
      label: context.l10n.reviewPhotoSemantics,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          file,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _AnalyzingView extends ConsumerWidget {
  const _AnalyzingView({required this.state, required this.onCancel});

  final MealCaptureState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PhotoPreview(imagePath: state.imagePath),
        const SizedBox(height: 28),
        Semantics(
          liveRegion: true,
          label: l10n.reviewAnalyzingMessage,
          child: const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.reviewAnalyzingMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.section.copyWith(
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.reviewAnalyzingHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: context.colorTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(mealCaptureProvider.notifier).switchToManual(),
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.reviewSwitchToManual),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onCancel, child: Text(l10n.reviewCancelAnalysis)),
      ],
    );
  }
}

class _FailedView extends ConsumerWidget {
  const _FailedView({required this.state});

  final MealCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(mealCaptureProvider.notifier);
    final message = switch (state.error) {
      MealCaptureError.proxyRequired => l10n.dashboardProxyRequired,
      MealCaptureError.consentRequired => l10n.aiConsentRequired,
      MealCaptureError.noFoodFound =>
        state.errorMessage?.isNotEmpty == true
            ? state.errorMessage!
            : l10n.dashboardNoFoodFound,
      _ =>
        state.errorMessage?.isNotEmpty == true
            ? state.errorMessage!
            : l10n.dashboardRecognitionError,
    };
    final canRetry =
        state.imagePath != null &&
        state.error != MealCaptureError.proxyRequired &&
        state.error != MealCaptureError.consentRequired;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PhotoPreview(imagePath: state.imagePath, height: 180),
        const SizedBox(height: 24),
        Icon(
          Icons.image_search_rounded,
          size: 40,
          color: context.colorWarningText,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: context.colorTextPrimary),
        ),
        const SizedBox(height: 24),
        if (canRetry) ...[
          ElevatedButton.icon(
            onPressed: controller.retryRecognition,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.reviewRetry),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: controller.switchToManual,
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.reviewSwitchToManual),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            controller.switchToManual(addBlank: false);
            context.push(
              AppRoutes.addMealLocation(date: state.dateTime, append: true),
            );
          },
          icon: const Icon(Icons.search_rounded),
          label: Text(l10n.reviewSearchAdd),
        ),
      ],
    );
  }
}

class _ReviewView extends ConsumerWidget {
  const _ReviewView({required this.state});

  final MealCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(mealCaptureProvider.notifier);
    final locale = context.localeTag;
    final confidence = state.confidence;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (state.imagePath != null) ...[
          _PhotoPreview(imagePath: state.imagePath, height: 170),
          const SizedBox(height: 12),
        ],
        if (state.summary?.isNotEmpty == true || confidence != null)
          Row(
            children: [
              if (state.summary?.isNotEmpty == true)
                Expanded(
                  child: Text(
                    state.summary!,
                    style: AppTextStyles.label.copyWith(
                      color: context.colorTextPrimary,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (confidence != null && confidence > 0)
                _Pill(
                  label: l10n.reviewConfidence((confidence * 100).round()),
                  color: context.colorPrimaryText,
                ),
            ],
          ),
        if (state.needsReview || (state.warning?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 12),
          _NoticeBanner(
            message: state.warning?.isNotEmpty == true
                ? '${l10n.reviewNeedsReview}\n${state.warning}'
                : l10n.reviewNeedsReview,
          ),
        ],
        const SizedBox(height: 18),
        _SectionLabel(label: l10n.reviewFoodsSection),
        const SizedBox(height: 8),
        if (state.drafts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.reviewNoDrafts,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
          ),
        for (final draft in state.drafts) ...[
          _DraftCard(key: ValueKey(draft.key), draft: draft),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.addBlankDraft,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.reviewAddManual),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  AppRoutes.addMealLocation(date: state.dateTime, append: true),
                ),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(l10n.reviewSearchAdd),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SectionLabel(label: l10n.mealDetailMealType),
        const SizedBox(height: 8),
        MealTypeChips(
          selected: state.mealType,
          onSelected: controller.setMealType,
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: l10n.reviewDateTime),
        const SizedBox(height: 8),
        DateTimeRow(
          value: state.dateTime,
          locale: locale,
          onChanged: controller.setDateTime,
        ),
      ],
    );
  }
}

class _SaveBar extends ConsumerStatefulWidget {
  const _SaveBar({required this.state});

  final MealCaptureState state;

  @override
  ConsumerState<_SaveBar> createState() => _SaveBarState();
}

class _SaveBarState extends ConsumerState<_SaveBar> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;
    final count = state.selectedDrafts.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: state.canSave && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.reviewSave(
                      count,
                      AppFormat.integer(
                        state.selectedCalories,
                        context.localeTag,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref.read(mealCaptureProvider.notifier).save();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewSaved(saved))));
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.dashboard);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }
}

class _DraftCard extends ConsumerStatefulWidget {
  const _DraftCard({super.key, required this.draft});

  final MealDraft draft;

  @override
  ConsumerState<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends ConsumerState<_DraftCard> {
  late final TextEditingController _name;
  late final TextEditingController _kcal;
  late final TextEditingController _carbs;
  late final TextEditingController _protein;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _name = TextEditingController(text: draft.name);
    // Like the record edit sheet, the fields show what is eaten at the
    // chosen portion; the draft keeps the 1× values.
    _kcal = TextEditingController(text: _number(draft.scaledCalories));
    _carbs = TextEditingController(text: _number(draft.scaledCarbs));
    _protein = TextEditingController(text: _number(draft.scaledProtein));
    _fat = TextEditingController(text: _number(draft.scaledFat));
  }

  void _setPortion(double portion) {
    _update((d) => d.copyWith(portion: portion));
    final draft = widget.draft.copyWith(portion: portion);
    _kcal.text = _number(draft.scaledCalories);
    _carbs.text = _number(draft.scaledCarbs);
    _protein.text = _number(draft.scaledProtein);
    _fat.text = _number(draft.scaledFat);
  }

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _carbs.dispose();
    _protein.dispose();
    _fat.dispose();
    super.dispose();
  }

  static String _number(num value) {
    if (value == 0) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  void _update(MealDraft Function(MealDraft draft) change) {
    ref
        .read(mealCaptureProvider.notifier)
        .updateDraft(widget.draft.key, change);
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final l10n = context.l10n;
    final isAi = draft.source == FoodSource.imageRecognition;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      borderColor: draft.isLowConfidence
          ? AppColors.warning.withValues(alpha: 0.6)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: draft.selected,
                semanticLabel: l10n.reviewSelectItem,
                onChanged: (value) =>
                    _update((d) => d.copyWith(selected: value ?? false)),
              ),
              Expanded(
                child: TextField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: context.colorTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.reviewNameHint,
                    isDense: true,
                  ),
                  onChanged: (value) => _update((d) => d.copyWith(name: value)),
                ),
              ),
              IconButton(
                tooltip: l10n.reviewRemoveItem,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colorTextTertiary,
                ),
                onPressed: () => ref
                    .read(mealCaptureProvider.notifier)
                    .removeDraft(draft.key),
              ),
            ],
          ),
          if (isAi || draft.servingSize?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (isAi && draft.confidence != null)
                    _Pill(
                      label: l10n.reviewConfidence(
                        ((draft.confidence ?? 0) * 100).round(),
                      ),
                      color: draft.isLowConfidence
                          ? context.colorWarningText
                          : context.colorPrimaryText,
                    ),
                  if (draft.isLowConfidence)
                    _Pill(
                      label: l10n.reviewLowConfidence,
                      color: context.colorWarningText,
                    ),
                  if (draft.servingSize?.isNotEmpty == true)
                    Text(
                      draft.servingSize!,
                      style: AppTextStyles.micro.copyWith(
                        color: context.colorTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _kcal,
                    label: 'kcal',
                    integer: true,
                    onChanged: (value) => _update(
                      (d) => d.copyWith(calories: (value / d.portion).round()),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NumberField(
                    controller: _carbs,
                    label: l10n.reviewCarbsLabel,
                    onChanged: (value) =>
                        _update((d) => d.copyWith(carbs: value / d.portion)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NumberField(
                    controller: _protein,
                    label: l10n.reviewProteinLabel,
                    onChanged: (value) =>
                        _update((d) => d.copyWith(protein: value / d.portion)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NumberField(
                    controller: _fat,
                    label: l10n.reviewFatLabel,
                    onChanged: (value) =>
                        _update((d) => d.copyWith(fat: value / d.portion)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  l10n.reviewPortion,
                  style: AppTextStyles.micro.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in MealReviewScreen.portionOptions)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(portionLabel(option)),
                              selected: draft.portion == option,
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) => _setPortion(option),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (draft.portion != 1.0)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Text(
                l10n.reviewPerPortion(
                  AppFormat.integer(draft.calories, context.localeTag),
                ),
                style: AppTextStyles.caption.copyWith(
                  color: context.colorSecondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `0.5×`, `1×`, `1.5×` …
String portionLabel(double option) {
  final text = option == option.roundToDouble()
      ? option.toStringAsFixed(0)
      : option.toString();
  return '$text×';
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.integer = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<num> onChanged;
  final bool integer;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
        ),
      ],
      textAlign: TextAlign.center,
      style: AppTextStyles.metric.copyWith(color: context.colorTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
      ),
      onChanged: (value) => onChanged(num.tryParse(value) ?? 0),
    );
  }
}

/// Meal type selector shared by the review screen and the record sheet.
class MealTypeChips extends StatelessWidget {
  const MealTypeChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final MealType selected;
  final ValueChanged<MealType> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MealType.values.map((type) {
        return ChoiceChip(
          label: Text(type.labelOf(context.l10n)),
          selected: type == selected,
          onSelected: enabled ? (_) => onSelected(type) : null,
        );
      }).toList(),
    );
  }
}

/// Date + time buttons with pickers. Dates are limited to the last two years
/// up to today.
class DateTimeRow extends StatelessWidget {
  const DateTimeRow({
    super.key,
    required this.value,
    required this.locale,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime value;
  final String locale;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? () => _pickDate(context) : null,
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(
              AppFormat.mediumDate(value, locale),
              semanticsLabel: l10n.reviewDateSemantics(
                AppFormat.fullDate(value, locale),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? () => _pickTime(context) : null,
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: Text(AppFormat.time(value)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = value.isAfter(now) ? now : value;
    // Meals older than the default range (e.g. opened from an old report
    // period) must still open the picker.
    final defaultFirst = DateTime(now.year - 2, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(defaultFirst) ? initial : defaultFirst,
      lastDate: now,
    );
    if (picked == null) return;
    onChanged(
      DateTime(picked.year, picked.month, picked.day, value.hour, value.minute),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked == null) return;
    onChanged(
      DateTime(value.year, value.month, value.day, picked.hour, picked.minute),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(color: context.colorTextSecondary),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: color)),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: context.colorWarningText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
