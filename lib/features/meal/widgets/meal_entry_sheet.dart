import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/meal_image_store.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/sheet_handle.dart';
import 'photo_picker.dart';

/// Entry point for logging a meal: photo (camera / album) or search and
/// manual entry. Search is always available, so meals can be logged without
/// the AI server or a network connection.
Future<void> showMealEntrySheet(
  BuildContext context,
  WidgetRef ref, {
  DateTime? date,
}) async {
  final choice = await showModalBottomSheet<_EntryChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _MealEntrySheet(date: date),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _EntryChoice.search:
      unawaited(context.push(AppRoutes.addMealLocation(date: date)));
    case _EntryChoice.camera:
    case _EntryChoice.gallery:
      final picked = await PhotoPicker.pick(
        context,
        choice == _EntryChoice.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (picked == null || !context.mounted) return;
      final stored = await MealImageStore.persist(picked.path);
      if (!context.mounted) return;
      unawaited(
        ref
            .read(mealCaptureProvider.notifier)
            .startFromImage(stored, date: date),
      );
      unawaited(context.push(AppRoutes.mealReview));
  }
}

enum _EntryChoice { camera, gallery, search }

class _MealEntrySheet extends ConsumerWidget {
  const _MealEntrySheet({this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final photoAvailable = ref
        .watch(foodImageRecognitionServiceProvider)
        .isConfigured;
    final today = ref.watch(todayDateProvider);
    final targetDate = date;
    final title = targetDate == null || targetDate.isSameDay(today)
        ? l10n.entrySheetTitle
        : l10n.entrySheetTitleForDate(
            AppFormat.mediumDate(targetDate, context.localeTag),
          );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.title.copyWith(
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _EntryTile(
              icon: Icons.camera_alt_rounded,
              title: l10n.entryCamera,
              subtitle: photoAvailable
                  ? l10n.entryCameraSubtitle
                  : l10n.entryPhotoUnavailable,
              enabled: photoAvailable,
              onTap: () => Navigator.pop(context, _EntryChoice.camera),
            ),
            const SizedBox(height: 10),
            _EntryTile(
              icon: Icons.photo_library_rounded,
              title: l10n.entryGallery,
              subtitle: photoAvailable
                  ? l10n.entryGallerySubtitle
                  : l10n.entryPhotoUnavailable,
              enabled: photoAvailable,
              onTap: () => Navigator.pop(context, _EntryChoice.gallery),
            ),
            const SizedBox(height: 10),
            _EntryTile(
              icon: Icons.search_rounded,
              title: l10n.entrySearch,
              subtitle: l10n.entrySearchSubtitle,
              onTap: () => Navigator.pop(context, _EntryChoice.search),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = enabled
        ? context.colorPrimaryText
        : context.colorTextTertiary;

    return Material(
      color: context.colorSurfaceVariant,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: enabled
                      ? context.colorPrimarySurface
                      : context.colorSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.section.copyWith(
                        color: enabled
                            ? context.colorTextPrimary
                            : context.colorTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colorTextTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
