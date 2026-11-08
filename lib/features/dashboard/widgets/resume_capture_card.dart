import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';

/// Offers to continue a meal review that was restored after the app was
/// closed (see MealCaptureController). Hidden when nothing is pending.
class ResumeCaptureCard extends ConsumerWidget {
  const ResumeCaptureCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(mealCaptureProvider);
    final pending =
        capture.status != MealCaptureStatus.idle &&
        capture.status != MealCaptureStatus.analyzing &&
        (capture.drafts.isNotEmpty || capture.imagePath != null);
    if (!pending) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restore_rounded, color: context.colorPrimaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.resumeCaptureTitle,
                    style: AppTextStyles.section.copyWith(
                      color: context.colorTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.resumeCaptureBody,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilledButton(
                  onPressed: () => context.push(AppRoutes.mealReview),
                  child: Text(l10n.resumeCaptureContinue),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(mealCaptureProvider.notifier).reset(),
                  child: Text(l10n.resumeCaptureDiscard),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
