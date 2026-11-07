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
              child: ActionChip(
                onPressed: () => onSuggestionTap(suggestion.label),
                avatar: AppSvgIcon(
                  suggestion.iconAsset,
                  color: context.colorPrimaryText,
                  size: 15,
                ),
                label: Text(suggestion.label),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimaryText,
                ),
                backgroundColor: context.colorPrimarySurface,
                side: BorderSide(
                  color: context.colorPrimaryText.withValues(alpha: 0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
