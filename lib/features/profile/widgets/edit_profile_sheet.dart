import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late String _gender;
  final _imagePicker = ImagePicker();
  String? _avatarImagePath;
  bool _isPickingAvatar = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _heightController = TextEditingController(
      text: profile.height.toStringAsFixed(0),
    );
    _weightController = TextEditingController(
      text: profile.currentWeight.toStringAsFixed(1),
    );
    _gender = profile.gender;
    _avatarImagePath = profile.avatarImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: l10n.commonBack,
                    color: context.colorTextPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileEditTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.colorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.profileEditSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colorTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: _ProfilePhotoEditor(
                imagePath: _avatarImagePath,
                isLoading: _isPickingAvatar,
                onTap: _showPhotoOptions,
              ),
            ),
            const SizedBox(height: 24),
            _buildField(l10n.profileName, _nameController, TextInputType.text),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    l10n.profileAge,
                    _ageController,
                    TextInputType.number,
                    suffix: Localizations.localeOf(context).languageCode == 'en'
                        ? 'y'
                        : '세',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    l10n.profileHeight,
                    _heightController,
                    TextInputType.number,
                    suffix: 'cm',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              l10n.profileCurrentWeight,
              _weightController,
              const TextInputType.numberWithOptions(decimal: true),
              suffix: 'kg',
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileGender,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderChip(
                    label: l10n.profileMale,
                    icon: Icons.male_rounded,
                    isSelected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderChip(
                    label: l10n.profileFemale,
                    icon: Icons.female_rounded,
                    isSelected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  l10n.profileSave,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colorTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPhotoOptions() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                _PhotoActionTile(
                  icon: Icons.photo_library_rounded,
                  title: context.l10n.profilePhotoGallery,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                _PhotoActionTile(
                  icon: Icons.photo_camera_rounded,
                  title: context.l10n.profilePhotoCamera,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                if (_avatarImagePath != null)
                  _PhotoActionTile(
                    icon: Icons.delete_outline_rounded,
                    title: context.l10n.profilePhotoDelete,
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() => _avatarImagePath = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    setState(() => _isPickingAvatar = true);

    try {
      final effectiveSource = _effectiveImageSource(source);
      if (effectiveSource != source) {
        _showMessage(context.l10n.dashboardCameraFallback);
      }

      final picked = await _imagePicker.pickImage(
        source: effectiveSource,
        maxWidth: 720,
        imageQuality: 82,
      );
      if (picked == null) return;

      final persistedPath = await _persistAvatarImage(picked);
      if (!mounted) return;
      setState(() => _avatarImagePath = persistedPath);
    } on PlatformException {
      if (!mounted) return;
      _showMessage(context.l10n.dashboardPhotoPermissionError);
    } finally {
      if (mounted) {
        setState(() => _isPickingAvatar = false);
      }
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

  Future<String> _persistAvatarImage(XFile picked) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDirectory = Directory('${directory.path}/profile_images');
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }

      final extension = _imageExtension(picked.path);
      final fileName = 'avatar_${const Uuid().v4()}$extension';
      final targetPath = '${imageDirectory.path}/$fileName';
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (name.isEmpty || age == null || height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileValidationError)),
      );
      return;
    }

    final profile = ref.read(userProfileProvider);
    ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          profile.copyWith(
            name: name,
            age: age,
            height: height,
            currentWeight: weight,
            gender: _gender,
            avatarImagePath: _avatarImagePath,
          ),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.profileUpdated),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ProfilePhotoEditor extends StatelessWidget {
  const _ProfilePhotoEditor({
    required this.imagePath,
    required this.isLoading,
    required this.onTap,
  });

  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && File(path).existsSync();

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: context.colorPrimarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colorBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image.file(File(path), fit: BoxFit.cover)
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 42,
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colorSurface, width: 3),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasImage
                ? context.l10n.profilePhotoChange
                : context.l10n.profilePhotoAdd,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoActionTile extends StatelessWidget {
  const _PhotoActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: color == AppColors.error ? color : context.colorTextPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colorTextTertiary,
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : context.colorSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.colorBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : context.colorTextSecondary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : context.colorTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
