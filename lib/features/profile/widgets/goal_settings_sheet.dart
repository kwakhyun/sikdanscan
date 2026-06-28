import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_svg_icon.dart';

class GoalSettingsSheet extends ConsumerStatefulWidget {
  const GoalSettingsSheet({super.key});

  @override
  ConsumerState<GoalSettingsSheet> createState() => _GoalSettingsSheetState();
}

class _GoalSettingsSheetState extends ConsumerState<GoalSettingsSheet> {
  late TextEditingController _targetWeightController;
  late TextEditingController _calorieGoalController;
  late TextEditingController _waterGoalController;
  late TextEditingController _stepGoalController;
  late WellnessGoal _wellnessGoal;
  late ActivityLevel _activityLevel;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _targetWeightController = TextEditingController(
      text: profile.targetWeight.toStringAsFixed(1),
    );
    _calorieGoalController = TextEditingController(
      text: profile.dailyCalorieGoal.toString(),
    );
    _waterGoalController = TextEditingController(
      text: profile.dailyWaterGoalMl.toString(),
    );
    _stepGoalController = TextEditingController(
      text: profile.dailyStepGoal.toString(),
    );
    _wellnessGoal = profile.wellnessGoal;
    _activityLevel = profile.activityLevel;
    _targetDate = profile.targetDate;
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _calorieGoalController.dispose();
    _waterGoalController.dispose();
    _stepGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: context.l10n.commonBack,
                    color: context.colorTextPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.goalSettingsTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.colorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.goalSettingsSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildWellnessGoalSelector(),
            const SizedBox(height: 20),
            _buildActivityLevelSelector(),
            const SizedBox(height: 20),
            _buildField(
              context.l10n.goalTargetWeight,
              _targetWeightController,
              const TextInputType.numberWithOptions(decimal: true),
              suffix: 'kg',
              icon: Icons.flag_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildField(
              context.l10n.goalCalorieTarget,
              _calorieGoalController,
              TextInputType.number,
              suffix: 'kcal',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 10),
            _buildCalorieRecommendation(profile),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context.l10n.goalWaterTarget,
                    _waterGoalController,
                    TextInputType.number,
                    suffix: 'ml',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    context.l10n.goalStepTarget,
                    _stepGoalController,
                    TextInputType.number,
                    suffix: context.l10n.goalStepSuffix,
                    icon: Icons.directions_walk_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  context.l10n.goalSettingsDone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.directions_run_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.goalActivityTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...ActivityLevel.values.map(
          (level) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ActivityLevelTile(
              level: level,
              selected: _activityLevel == level,
              onTap: () => setState(() => _activityLevel = level),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieRecommendation(UserProfile profile) {
    final recommendation = profile
        .copyWith(wellnessGoal: _wellnessGoal, activityLevel: _activityLevel)
        .recommendedDailyCalorieGoal;
    if (recommendation <= 0) {
      return const SizedBox.shrink();
    }

    final basis = _calorieGoalBasisSummary(
      profile.copyWith(
        wellnessGoal: _wellnessGoal,
        activityLevel: _activityLevel,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 17,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${context.l10n.goalRecommendation} $recommendation kcal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(
                  () => _calorieGoalController.text = recommendation.toString(),
                ),
                child: Text(context.l10n.goalApply),
              ),
            ],
          ),
          Text(
            basis,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: context.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.goalDirectionTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WellnessGoal.values
              .map(
                (goal) => _WellnessGoalChip(
                  goal: goal,
                  selected: _wellnessGoal == goal,
                  onTap: () => setState(() => _wellnessGoal = goal),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _wellnessGoal.descriptionOf(context.l10n),
          style: TextStyle(fontSize: 12, color: context.colorTextTertiary),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    String? suffix,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.goalTargetDate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: context.colorBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _targetDate != null
                      ? _formatDate(_targetDate!)
                      : context.l10n.goalSelectDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: _targetDate != null
                        ? context.colorTextPrimary
                        : context.colorTextTertiary,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: context.colorTextTertiary,
                ),
              ],
            ),
          ),
        ),
        if (_targetDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'D-${_targetDate!.difference(DateTime.now()).inDays}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (isEnglish) {
      return '${date.month}/${date.day}/${date.year}';
    }
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _calorieGoalBasisSummary(UserProfile profile) {
    if (!profile.hasBodyMetrics || profile.maintenanceCalorieEstimate <= 0) {
      return context.l10n.onboardingCheckInputs;
    }

    final adjustment = profile.goalCalorieAdjustment;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final adjustmentText = adjustment == 0
        ? (isEnglish ? 'no goal adjustment' : '목표 보정 없음')
        : '${adjustment > 0 ? '+' : ''}$adjustment kcal ${isEnglish ? 'goal adjustment' : '목표 보정'}';
    return 'BMR ${profile.basalMetabolicRate.round()} kcal × ${profile.activityLevel.labelOf(context.l10n)} ${profile.activityLevel.factor.toStringAsFixed(2)} · $adjustmentText';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _save() {
    final targetWeight = double.tryParse(_targetWeightController.text);
    final calorieGoal = int.tryParse(_calorieGoalController.text);
    final waterGoal = int.tryParse(_waterGoalController.text);
    final stepGoal = int.tryParse(_stepGoalController.text);

    if (targetWeight == null ||
        calorieGoal == null ||
        waterGoal == null ||
        stepGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileValidationError)),
      );
      return;
    }

    final profile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          profile.copyWith(
            targetWeight: targetWeight,
            dailyCalorieGoal: calorieGoal,
            activityLevel: _activityLevel,
            dailyWaterGoalMl: waterGoal,
            dailyStepGoal: stepGoal,
            wellnessGoal: _wellnessGoal,
            targetDate: _targetDate,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.goalUpdated),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _WellnessGoalChip extends StatelessWidget {
  const _WellnessGoalChip({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final WellnessGoal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: AppSvgIcon(
        goal.iconAsset,
        size: 16,
        color: selected ? Colors.white : AppColors.primary,
      ),
      label: Text(goal.labelOf(context.l10n)),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : context.colorTextSecondary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: context.colorSurfaceVariant,
      side: BorderSide(
        color: selected ? AppColors.primary : context.colorBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      showCheckmark: false,
    );
  }
}

class _ActivityLevelTile extends StatelessWidget {
  const _ActivityLevelTile({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final ActivityLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? context.colorPrimarySurface : context.colorSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : context.colorBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : context.colorTextTertiary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.labelOf(context.l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.descriptionOf(context.l10n),
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
