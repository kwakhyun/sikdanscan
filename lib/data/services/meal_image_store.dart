import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
      await File(sourcePath).copy('$documents/$relative');
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
