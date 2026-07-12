import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'widgets/daily_intake_overview_card.dart';
import 'widgets/goal_strategy_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _imagePicker = ImagePicker();
  bool _isRecognizingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              sliver: SliverList.list(
                children: [
                  const GoalStrategyCard(),
                  const SizedBox(height: 14),
                  const DailyIntakeOverviewCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _CaptureFloatingButton(
        isLoading: _isRecognizingImage,
        onPressed: _showCaptureSourceSheet,
      ),
    );
  }

  Future<void> _showCaptureSourceSheet() async {
    if (_isRecognizingImage) return;
    final l10n = context.l10n;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              _CaptureSourceTile(
                icon: Icons.camera_alt_rounded,
                title: l10n.dashboardCaptureNow,
                subtitle: l10n.dashboardCaptureNowSubtitle,
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _CaptureSourceTile(
                icon: Icons.photo_library_rounded,
                title: l10n.dashboardPickPhoto,
                subtitle: l10n.dashboardPickPhotoSubtitle,
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _captureRecognizeAndSave(source);
    }
  }

  Future<void> _captureRecognizeAndSave(ImageSource source) async {
    final service = ref.read(foodImageRecognitionServiceProvider);
    final l10n = context.l10n;
    if (!service.isConfigured) {
      _showMessage(l10n.dashboardProxyRequired);
      return;
    }

    final picked = await _pickMealImage(source);
    if (picked == null) return;

    setState(() => _isRecognizingImage = true);

    try {
      final imagePath = await _persistMealImage(picked);
      final result = await service.recognizeImageFile(
        imagePath,
        locale: ref.read(languageProvider).languageCode,
      );
      final foods = result.items
          .map((item) => _recognizedItemToFood(item, imagePath: imagePath))
          .toList();

      if (!mounted) return;
      if (foods.isEmpty) {
        _showMessage(
          result.warning?.isNotEmpty == true
              ? result.warning!
              : l10n.dashboardNoFoodFound,
        );
        return;
      }

      final now = DateTime.now();
      final notifier = ref.read(mealRecordsProvider.notifier);
      const uuid = Uuid();

      for (final food in foods) {
        await notifier.addMeal(
          food.toMealRecord(
            id: uuid.v4(),
            date: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            mealType: MealType.fromTime(now),
          ),
        );
      }

      ref.read(selectedDateProvider.notifier).state = DateTime(
        now.year,
        now.month,
        now.day,
      );

      _showMessage(
        result.needsReview
            ? l10n.dashboardAddedEstimated
            : l10n.dashboardAddedAnalyzed,
      );
    } on FoodImageRecognitionException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage(l10n.dashboardRecognitionError);
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
      return await _imagePicker.pickImage(
        source: effectiveSource,
        maxWidth: 1280,
        imageQuality: 82,
      );
    } on PlatformException {
      if (source == ImageSource.camera &&
          effectiveSource != ImageSource.gallery &&
          _imagePicker.supportsImageSource(ImageSource.gallery)) {
        _showMessage(context.l10n.dashboardCameraFallback);
        try {
          return await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1280,
            imageQuality: 82,
          );
        } on PlatformException {
          // The generic permission/source message below covers the failure.
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

  Future<String> _persistMealImage(XFile picked) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDirectory = Directory('${directory.path}/meal_images');
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }

      final targetPath =
          '${imageDirectory.path}/meal_${const Uuid().v4()}${_imageExtension(picked.path)}';
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
}

class _CaptureFloatingButton extends StatelessWidget {
  const _CaptureFloatingButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.camera_alt_rounded),
      label: Text(
        isLoading
            ? context.l10n.commonAnalyzing
            : context.l10n.dashboardCapture,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _CaptureSourceTile extends StatelessWidget {
  const _CaptureSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorSurfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colorTextTertiary),
          ],
        ),
      ),
    );
  }
}
