import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'image_metadata.dart';

/// Stores captured images inside the app documents directory and keeps only
/// a *relative* path (e.g. `meal_images/meal_<uuid>.jpg`) in records.
///
/// iOS can move the app container between updates, so absolute paths stored
/// in earlier versions are re-resolved against the current documents
/// directory by their folder + file name.
class MealImageStore {
  MealImageStore._();

  static const mealFolder = 'meal_images';
  static const profileFolder = 'profile_images';
  static const _knownFolders = [mealFolder, profileFolder];

  static String? _documentsPath;

  static Future<void> initialize() async {
    try {
      _documentsPath = (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      _documentsPath = null;
    }
  }

  @visibleForTesting
  static void debugSetDocumentsPath(String? path) => _documentsPath = path;

  /// Copies [sourcePath] into the documents directory and returns the
  /// relative path to store. Falls back to the original path on failure.
  static Future<String> persist(
    String sourcePath, {
    String folder = mealFolder,
    String prefix = 'meal',
  }) async {
    final documents = _documentsPath;
    if (documents == null) return sourcePath;

    try {
      final directory = Directory('$documents/$folder');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final relative =
          '$folder/${prefix}_${const Uuid().v4()}${_extension(sourcePath)}';
      final bytes = await File(sourcePath).readAsBytes();
      // The stored copy is what gets uploaded and analysed: drop the
      // location the camera may have written into it.
      await File('$documents/$relative').writeAsBytes(stripJpegGps(bytes));
      return relative;
    } catch (_) {
      return sourcePath;
    }
  }

  /// Returns an existing local file for a stored path, or `null`.
  static File? resolveFile(String? stored) {
    final path = resolvePath(stored);
    return path == null ? null : File(path);
  }

  static String? resolvePath(String? stored) {
    final value = stored?.trim();
    if (value == null || value.isEmpty) return null;

    try {
      if (_isAbsolute(value)) {
        if (File(value).existsSync()) return value;
        final relocated = _relocateLegacyPath(value);
        if (relocated != null && File(relocated).existsSync()) {
          return relocated;
        }
        return null;
      }

      final documents = _documentsPath;
      if (documents == null) return null;
      final absolute = '$documents/$value';
      return File(absolute).existsSync() ? absolute : null;
    } catch (_) {
      return null;
    }
  }

  /// Converts a legacy absolute path into the relative form when it points
  /// inside one of the app image folders.
  static String normalizeForStorage(String? stored) {
    final value = stored?.trim() ?? '';
    if (value.isEmpty || !_isAbsolute(value)) return value;
    for (final folder in _knownFolders) {
      final marker = '/$folder/';
      final index = value.lastIndexOf(marker);
      if (index >= 0) return value.substring(index + 1);
    }
    return value;
  }

  static Future<void> delete(String? stored) async {
    final path = resolvePath(stored);
    if (path == null) return;
    try {
      await File(path).delete();
    } catch (_) {
      // Missing files are fine; the record no longer references them.
    }
  }

  /// Deletes every stored meal and profile photo (data reset / account
  /// deletion). Each folder is handled separately so one failure does not
  /// keep the others.
  static Future<void> clearAll() async {
    final documents = _documentsPath;
    if (documents == null) return;
    for (final folder in _knownFolders) {
      try {
        final directory = Directory('$documents/$folder');
        if (await directory.exists()) await directory.delete(recursive: true);
      } catch (_) {
        // Best effort: a locked file must not block the reset.
      }
    }
  }

  /// Detects JPEG, PNG or WebP from the file header. Image pickers re-encode
  /// resized photos but can keep the original name (e.g. `scaled_x.heic`
  /// holding JPEG bytes), so the name alone is not reliable.
  static String? sniffContentType(List<int> bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
      const heifBrands = {
        'heic',
        'heix',
        'hevc',
        'hevx',
        'heif',
        'mif1',
        'msf1',
      };
      final brand = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
      if (heifBrands.contains(brand)) return 'image/heic';
    }
    return null;
  }

  static String extensionForContentType(String contentType) {
    return switch (contentType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      _ => 'jpg',
    };
  }

  static String extensionOf(String path) => _extension(path).substring(1);

  static String contentTypeOf(String path) {
    return switch (extensionOf(path)) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }

  static String? _relocateLegacyPath(String absolute) {
    final documents = _documentsPath;
    if (documents == null) return null;
    final relative = normalizeForStorage(absolute);
    if (relative == absolute) return null;
    return '$documents/$relative';
  }

  static bool _isAbsolute(String path) {
    return path.startsWith('/') || RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path);
  }

  static String _extension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.heic')) return '.heic';
    return '.jpg';
  }
}
