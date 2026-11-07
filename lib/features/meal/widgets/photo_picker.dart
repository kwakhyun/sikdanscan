import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations_context.dart';

/// Image picking with a gallery fallback when the camera is unavailable and
/// user-facing messages for permission failures.
class PhotoPicker {
  PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pick(
    BuildContext context,
    ImageSource source, {
    double maxWidth = 1280,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;

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
