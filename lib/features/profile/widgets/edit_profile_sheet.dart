import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/meal_image_store.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../meal/widgets/photo_picker.dart';
import 'weight_card.dart';

Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const EditProfileSheet(),
  );
}

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
  String? _avatarImagePath;
  String? _initialAvatarPath;
  bool _saving = false;
  bool _saved = false;
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
    // Same source the save compares against, so an untouched field never
    // logs a new weight.
    final weight = ref.read(currentWeightProvider);
    _weightController = TextEditingController(
      text: (weight > 0 ? weight : profile.currentWeight).toStringAsFixed(1),
    );
    _gender = profile.gender;
    _avatarImagePath = profile.avatarImagePath;
    _initialAvatarPath = profile.avatarImagePath;
  }

  @override
  void dispose() {
    // A photo picked but never saved is not referenced anywhere.
    if (!_saved && _avatarImagePath != _initialAvatarPath) {
      MealImageStore.delete(_avatarImagePath);
    }
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
                    suffix: l10n.unitYears,
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
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Text(
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
                    destructive: true,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _replaceAvatar(null);
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
      final picked = await PhotoPicker.pick(
        context,
        source,
        maxWidth: 720,
        purpose: PhotoPicker.avatarPurpose,
      );
      if (picked == null) return;
      final stored = await MealImageStore.persist(
        picked.path,
        folder: MealImageStore.profileFolder,
        prefix: 'avatar',
      );
      if (!mounted) return;
      _replaceAvatar(stored);
    } finally {
      if (mounted) setState(() => _isPickingAvatar = false);
    }
  }

  /// Swaps the pending avatar, deleting an earlier unsaved pick.
  void _replaceAvatar(String? next) {
    final previous = _avatarImagePath;
    if (previous != null &&
        previous != _initialAvatarPath &&
        previous != next) {
      MealImageStore.delete(previous);
    }
    setState(() => _avatarImagePath = next);
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty ||
        age == null ||
        age < 10 ||
        age > 100 ||
        height == null ||
        height < 100 ||
        height > 230 ||
        weight == null ||
        weight < 30 ||
        weight > 250) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileValidationError)));
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = ref.read(userProfileProvider);
      final weightChanged =
          (weight - ref.read(currentWeightProvider)).abs() >= 0.05;
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            profile.copyWith(
              name: name,
              age: age,
              height: height,
              gender: _gender,
              avatarImagePath: _avatarImagePath,
            ),
          );
      _saved = true;
      if (_initialAvatarPath != null &&
          _initialAvatarPath != _avatarImagePath) {
        MealImageStore.delete(_initialAvatarPath);
      }
      if (!mounted) return;

      if (weightChanged) {
        // Logging keeps the weight trend and offers a calorie target update.
        await logWeight(
          context,
          ref,
          weight,
          previousRecommendation: profile.recommendedDailyCalorieGoal,
          previousWaterRecommendation: profile.recommendedWaterGoalMl,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
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
    final file = MealImageStore.resolveFile(imagePath);
    final hasImage = file != null;

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
                    ? Image.file(file, fit: BoxFit.cover)
                    : Icon(
                        Icons.person_rounded,
                        color: context.colorPrimaryText,
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
                    color: AppColors.primaryStrong,
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: context.colorPrimaryText,
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
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? context.colorErrorText
        : context.colorPrimaryText;
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
          color: destructive ? color : context.colorTextPrimary,
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
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryStrong
                : context.colorSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryStrong : context.colorBorder,
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
      ),
    );
  }
}
