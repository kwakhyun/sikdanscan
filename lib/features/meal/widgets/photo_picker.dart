import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/services/local_storage_service.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Image picking with a gallery fallback when the camera is unavailable and
/// user-facing messages for permission failures.
class PhotoPicker {
  PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();
  static const _purposeKey = 'photo_picker_purpose';
  static const mealPurpose = 'meal';
  static const avatarPurpose = 'avatar';

  /// Android can destroy the app while the camera is open; the photo then
  /// arrives on the next start. Returns it when it was taken for a meal.
  static Future<XFile?> retrieveLostMealPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    final storage = LocalStorageService();
    String? purpose;
    try {
      purpose = storage.getSetting<String>(_purposeKey);
      await storage.removeSetting(_purposeKey);
    } catch (_) {}
    if (purpose == null) return null;
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty || purpose != mealPurpose) return null;
      return response.file ?? response.files?.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  static Future<XFile?> pick(
    BuildContext context,
    ImageSource source, {
    double maxWidth = 1280,
    String purpose = mealPurpose,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    await _setPurpose(purpose);
    try {
      return await _pick(messenger, l10n, source, maxWidth: maxWidth);
    } finally {
      await _setPurpose(null);
    }
  }

  static Future<void> _setPurpose(String? purpose) async {
    try {
      final storage = LocalStorageService();
      if (purpose == null) {
        await storage.removeSetting(_purposeKey);
      } else {
        await storage.saveSetting(_purposeKey, purpose);
      }
    } catch (_) {
      // Without storage a lost photo simply is not recovered.
    }
  }

  static Future<XFile?> _pick(
    ScaffoldMessengerState? messenger,
    AppLocalizations l10n,
    ImageSource source, {
    required double maxWidth,
  }) async {
    void show(String message) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }

    var effective = source;
    if (source == ImageSource.camera &&
        !_picker.supportsImageSource(ImageSource.camera) &&
        _picker.supportsImageSource(ImageSource.gallery)) {
      effective = ImageSource.gallery;
      show(l10n.dashboardCameraFallback);
    }

    try {
      return await _picker.pickImage(
        source: effective,
        maxWidth: maxWidth,
        imageQuality: 82,
      );
    } on PlatformException {
      if (effective == ImageSource.camera &&
          _picker.supportsImageSource(ImageSource.gallery)) {
        show(l10n.dashboardCameraFallback);
        try {
          return await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: maxWidth,
            imageQuality: 82,
          );
        } on PlatformException {
          // Falls through to the permission message.
        }
      }
      show(l10n.dashboardPhotoPermissionError);
      return null;
    }
  }
}
