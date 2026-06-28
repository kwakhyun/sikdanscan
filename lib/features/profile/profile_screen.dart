import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final records = ref.watch(weightRecordsProvider);
    final currentWeight = records.isNotEmpty
        ? records.last.weight
        : profile.currentWeight;
    final bmi = profile.currentWeight > 0
        ? profile.copyWith(currentWeight: currentWeight).bmi
        : 0.0;
    final bmiCategory = profile.currentWeight > 0
        ? profile.copyWith(currentWeight: currentWeight).bmiCategory
        : context.l10n.profileFallbackNeedsSetup;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,
            pinned: true,
            backgroundColor: AppColors.primary,
            toolbarHeight: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.cardGradient,
                ),
                child: _ProfileHero(
                  profile: profile,
                  onEdit: () => _showEditProfile(context),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(
                        title: 'BMI',
                        value: bmi > 0 ? bmi.toStringAsFixed(1) : '-',
                        subtitle: bmiCategory,
                        icon: Icons.monitor_heart_outlined,
                        color: _getBmiColor(bmi),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStatCard(
                        title: l10n.profileCurrentWeight,
                        value: currentWeight > 0
                            ? '${currentWeight.toStringAsFixed(1)}kg'
                            : '-',
                        subtitle: profile.onboardingCompleted
                            ? l10n.profileInitialInputBasis
                            : l10n.profileFallbackNeedsSetup,
                        icon: Icons.monitor_weight_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(
                        title: l10n.profileDailyGoal,
                        value: profile.dailyCalorieGoal > 0
                            ? '${profile.dailyCalorieGoal}'
                            : '-',
                        subtitle: 'kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStatCard(
                        title: l10n.profileWellnessGoal,
                        value: profile.wellnessGoal.labelOf(l10n),
                        subtitle: profile.activityLevel.labelOf(l10n),
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CalorieGoalBasisCard(profile: profile),
                const SizedBox(height: 24),
                const SettingsSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi <= 0) return AppColors.textTertiary;
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 23) return AppColors.success;
    if (bmi < 25) return AppColors.warning;
    return AppColors.error;
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const EditProfileSheet(),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final gender = profile.gender == 'male'
        ? l10n.profileMale
        : l10n.profileFemale;
    final bodyText = profile.hasBodyMetrics
        ? '${profile.age}${isEnglish ? 'y' : '세'} · ${profile.height.toStringAsFixed(0)}cm · $gender'
        : l10n.profileBodyNotConfigured;
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topInset + 4, 20, 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            _ProfileAvatar(profile: profile, onTap: onEdit),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bodyText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: onEdit,
                tooltip: l10n.profileEditTooltip,
                icon: const Icon(Icons.edit_rounded, size: 19),
                color: AppColors.primaryDark,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.onTap});

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarPath = profile.avatarImagePath;
    final hasAvatar = avatarPath != null && File(avatarPath).existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAvatar
                ? Image.file(File(avatarPath), fit: BoxFit.cover)
                : const Icon(
                    Icons.person_rounded,
                    size: 25,
                    color: Colors.white,
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 10,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieGoalBasisCard extends StatelessWidget {
  const _CalorieGoalBasisCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final recommended = profile.recommendedDailyCalorieGoal;
    final current = profile.dailyCalorieGoal;
    final isCustom = recommended > 0 && current > 0 && recommended != current;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.secondary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileCalorieBasisTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.colorTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCustom
                          ? context.l10n.profileCalorieBasisCustom
                          : context.l10n.profileCalorieBasisAuto,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.calorieGoalBasisSummary,
            style: TextStyle(
              fontSize: 13,
              height: 1.48,
              color: context.colorTextSecondary,
            ),
          ),
          if (recommended > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _BasisPill(label: '권장 $recommended kcal'),
                _BasisPill(
                  label: '현재 ${current > 0 ? current : recommended} kcal',
                ),
                _BasisPill(label: '수분 ${profile.dailyWaterGoalMl} ml'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BasisPill extends StatelessWidget {
  const _BasisPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: context.colorTextSecondary,
        ),
      ),
    );
  }
}
