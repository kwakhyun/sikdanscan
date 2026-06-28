import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_svg_icon.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int _step = 0;
  String _gender = 'female';
  WellnessGoal _goal = WellnessGoal.skinHealth;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  bool _saving = false;

  static const _stepCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(
              step: _step,
              stepCount: _stepCount,
              onBack: _step > 0 && !_saving ? _previous : null,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(),
                  _buildGoalStep(),
                  _buildBodyMetricsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return _StepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.onboardingStartTitle,
            style: TextStyle(
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w900,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboardingStartSubtitle,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 30),
          _BenefitRow(
            icon: Icons.flash_on_rounded,
            title: context.l10n.onboardingBenefitQuickTitle,
            description: context.l10n.onboardingBenefitQuickDescription,
          ),
          const SizedBox(height: 14),
          _BenefitRow(
            icon: Icons.calculate_rounded,
            title: context.l10n.onboardingBenefitCalorieTitle,
            description: context.l10n.onboardingBenefitCalorieDescription,
          ),
          const SizedBox(height: 14),
          _BenefitRow(
            icon: Icons.auto_awesome_rounded,
            title: context.l10n.onboardingBenefitCoachTitle,
            description: context.l10n.onboardingBenefitCoachDescription,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return _StepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: context.l10n.onboardingGoalTitle,
            subtitle: context.l10n.onboardingGoalSubtitle,
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.separated(
              itemCount: WellnessGoal.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final goal = WellnessGoal.values[index];
                return _SelectableTile(
                  selected: _goal == goal,
                  iconAsset: goal.iconAsset,
                  title: goal.labelOf(context.l10n),
                  description: goal.descriptionOf(context.l10n),
                  onTap: () => setState(() => _goal = goal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsStep() {
    return _StepPadding(
      child: ListView(
        children: [
          _StepTitle(
            title: context.l10n.onboardingMetricsTitle,
            subtitle: context.l10n.onboardingMetricsSubtitle,
          ),
          const SizedBox(height: 22),
          _OnboardingTextField(
            label: context.l10n.onboardingNickname,
            hint: context.l10n.onboardingNicknameHint,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OnboardingTextField(
                  label: context.l10n.profileAge,
                  hint: '30',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffix: Localizations.localeOf(context).languageCode == 'en'
                      ? 'y'
                      : '세',
                  icon: Icons.cake_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OnboardingTextField(
                  label: context.l10n.profileHeight,
                  hint: '165',
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffix: 'cm',
                  icon: Icons.height_rounded,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _OnboardingTextField(
            label: context.l10n.profileCurrentWeight,
            hint: '68.0',
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _SectionLabel(
            icon: Icons.wc_rounded,
            label: context.l10n.profileGender,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: context.l10n.profileFemale,
                  selected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SegmentButton(
                  label: context.l10n.profileMale,
                  selected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionLabel(
            icon: Icons.directions_run_rounded,
            label: context.l10n.onboardingActivityTitle,
          ),
          const SizedBox(height: 8),
          ...ActivityLevel.values.map(
            (level) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableTile(
                selected: _activityLevel == level,
                iconAsset: level.iconAsset,
                title: level.labelOf(context.l10n),
                description: level.descriptionOf(context.l10n),
                onTap: () => setState(() => _activityLevel = level),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final draft = _draftProfile();
    final calorieGoal = draft?.recommendedDailyCalorieGoal ?? 0;
    final waterGoal = draft?.recommendedWaterGoalMl ?? 0;

    return _StepPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            title: context.l10n.onboardingReviewTitle,
            subtitle: context.l10n.onboardingReviewSubtitle,
          ),
          const SizedBox(height: 22),
          _ReviewMetricCard(
            icon: Icons.local_fire_department_rounded,
            title: context.l10n.onboardingTargetCalories,
            value: calorieGoal > 0
                ? '$calorieGoal kcal'
                : context.l10n.onboardingNeedsCalculation,
            description: draft != null
                ? _calorieGoalBasisSummary(draft)
                : context.l10n.onboardingCheckInputs,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _ReviewMetricCard(
            icon: Icons.water_drop_rounded,
            title: context.l10n.onboardingWaterBasis,
            value: waterGoal > 0
                ? '$waterGoal ml'
                : context.l10n.onboardingNeedsCalculation,
            description: context.l10n.onboardingWaterBasisDescription,
            color: AppColors.info,
          ),
          const SizedBox(height: 12),
          _ReviewMetricCard(
            icon: Icons.auto_awesome_rounded,
            iconAsset: _goal.iconAsset,
            title: context.l10n.profileWellnessGoal,
            value: _goal.labelOf(context.l10n),
            description: _goal.descriptionOf(context.l10n),
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colorPrimarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.onboardingReviewInfo,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      decoration: BoxDecoration(
        color: context.colorBackground,
        border: Border(top: BorderSide(color: context.colorDivider)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: _saving ? null : _previous,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: context.colorBorder),
                  foregroundColor: context.colorTextPrimary,
                ),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _step == 0
                            ? context.l10n.onboardingQuickStart
                            : _step == _stepCount - 1
                            ? context.l10n.onboardingStartFlow
                            : context.l10n.commonNext,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previous() {
    if (_step == 0) return;
    _goToStep(_step - 1);
  }

  Future<void> _next() async {
    if (_step == 2 && !_validateBodyMetrics()) return;
    if (_step == _stepCount - 1) {
      await _completeOnboarding();
      return;
    }
    _goToStep(_step + 1);
  }

  void _goToStep(int nextStep) {
    setState(() => _step = nextStep);
    _pageController.animateToPage(
      nextStep,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  bool _validateBodyMetrics() {
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (age == null || age < 10 || age > 100) {
      _showError(context.l10n.onboardingValidationAge);
      return false;
    }
    if (height == null || height < 100 || height > 230) {
      _showError(context.l10n.onboardingValidationHeight);
      return false;
    }
    if (weight == null || weight < 30 || weight > 250) {
      _showError(context.l10n.onboardingValidationWeight);
      return false;
    }
    return true;
  }

  Future<void> _completeOnboarding() async {
    final draft = _draftProfile();
    if (draft == null) {
      _showError(context.l10n.onboardingCheckInputs);
      return;
    }

    final profile = draft.copyWith(
      dailyCalorieGoal: draft.recommendedDailyCalorieGoal,
      dailyWaterGoalMl: draft.recommendedWaterGoalMl,
      dailyStepGoal: _activityLevel.stepGoal,
      onboardingCompleted: true,
      onboardedAt: DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      await ref.read(userProfileProvider.notifier).updateProfile(profile);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (_) {
      if (!mounted) return;
      _showError(context.l10n.onboardingSaveFailed);
      setState(() => _saving = false);
    }
  }

  UserProfile? _draftProfile() {
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    if (age == null || height == null || weight == null) return null;

    final targetWeight = switch (_goal) {
      WellnessGoal.weightLoss =>
        (weight - (weight * 0.05).clamp(2.0, 6.0)).clamp(30.0, weight),
      WellnessGoal.muscle => weight,
      _ => weight,
    };

    return UserProfile(
      name: _nameController.text.trim().isEmpty
          ? context.l10n.defaultUserName
          : _nameController.text.trim(),
      age: age,
      height: height,
      startingWeight: weight,
      currentWeight: weight,
      targetWeight: targetWeight.toDouble(),
      gender: _gender,
      wellnessGoal: _goal,
      activityLevel: _activityLevel,
      targetDate: _goal == WellnessGoal.weightLoss
          ? DateTime.now().add(const Duration(days: 90))
          : null,
    );
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class AppStartGate extends ConsumerWidget {
  const AppStartGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.go(profile.onboardingCompleted ? '/dashboard' : '/onboarding');
    });

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.step,
    required this.stepCount,
    this.onBack,
  });

  final int step;
  final int stepCount;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: context.l10n.commonBack,
                color: context.colorTextPrimary,
                style: IconButton.styleFrom(
                  backgroundColor: context.colorSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: context.colorBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Row(
              children: List.generate(stepCount, (index) {
                final active = index <= step;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(
                      right: index == stepCount - 1 ? 0 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : context.colorBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPadding extends StatelessWidget {
  const _StepPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(24), child: child);
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 25,
            height: 1.18,
            fontWeight: FontWeight.w900,
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.48,
            fontWeight: FontWeight.w500,
            color: context.colorTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colorBorder),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? context.colorPrimarySurface : context.colorSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : context.colorBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : context.colorSurfaceVariant,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                iconAsset,
                size: 22,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.colorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : context.colorTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: icon, label: label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: context.colorSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colorBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colorBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.colorTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : context.colorSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : context.colorBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : context.colorTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _ReviewMetricCard extends StatelessWidget {
  const _ReviewMetricCard({
    required this.icon,
    this.iconAsset,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String value;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: iconAsset == null
                ? Icon(icon, color: color, size: 22)
                : AppSvgIcon(iconAsset!, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colorTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.42,
                    color: context.colorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
