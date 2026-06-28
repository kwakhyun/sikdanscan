import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_svg_icon.dart';

class SuggestionChips extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SuggestionChips({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final suggestions = [
      _SuggestionChipData(
        label: l10n.suggestionCalories,
        iconAsset: 'assets/icons/app/chat_calorie.svg',
      ),
      _SuggestionChipData(
        label: l10n.suggestionExercise,
        iconAsset: 'assets/icons/app/chat_activity.svg',
      ),
      _SuggestionChipData(
        label: l10n.suggestionWater,
        iconAsset: 'assets/icons/app/chat_water.svg',
      ),
      _SuggestionChipData(
        label: l10n.suggestionWeight,
        iconAsset: 'assets/icons/app/chat_weight.svg',
      ),
      _SuggestionChipData(
        label: l10n.suggestionSnack,
        iconAsset: 'assets/icons/app/chat_snack.svg',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSuggestionTap(suggestion.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorPrimarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(
                        suggestion.iconAsset,
                        color: AppColors.primary,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        suggestion.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SuggestionChipData {
  const _SuggestionChipData({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}
