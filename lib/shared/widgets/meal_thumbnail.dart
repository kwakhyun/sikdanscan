import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/meal_image_store.dart';
import '../../providers/service_providers.dart';

/// Signed URL for a meal photo stored in Supabase Storage (used when the
/// photo was taken on another device).
final signedMealImageUrlProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, storagePath) async {
      final service = ref.watch(supabaseBackendServiceProvider);
      if (!service.isConfigured || service.currentUser == null) return null;
      try {
        return await service.createSignedImageUrl(
          bucket: 'meal-images',
          path: storagePath,
          expiresInSeconds: 60 * 30,
        );
      } catch (_) {
        return null;
      }
    });

/// Meal photo from the local file, falling back to the cloud copy, then to a
/// placeholder icon.
class MealThumbnail extends ConsumerWidget {
  const MealThumbnail({
    super.key,
    this.imageUrl,
    this.storagePath,
    this.size = 56,
    this.radius = 12,
    this.semanticLabel,
  });

  final String? imageUrl;
  final String? storagePath;
  final double size;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = Center(
      child: Icon(
        Icons.restaurant_rounded,
        color: context.colorPrimaryText,
        size: size * 0.42,
      ),
    );

    Widget content = placeholder;
    final file = MealImageStore.resolveFile(imageUrl);
    if (file != null) {
      content = Image.file(
        file,
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (storagePath != null && storagePath!.isNotEmpty) {
      final url = ref.watch(signedMealImageUrlProvider(storagePath!));
      final value = url.valueOrNull;
      if (value != null) {
        content = Image.network(
          value,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        );
      }
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: size,
          height: size,
          color: context.colorSurfaceVariant,
          child: content,
        ),
      ),
    );
  }
}
