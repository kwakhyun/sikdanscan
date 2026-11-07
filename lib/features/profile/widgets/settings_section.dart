import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/proxy_status_service.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_svg_icon.dart';
import '../../../shared/widgets/sheet_handle.dart';
import 'edit_profile_sheet.dart';
import 'goal_settings_sheet.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themePreferenceProvider);
    final language = ref.watch(languageProvider);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Semantics(
              header: true,
              child: Text(
                l10n.settingsTitle,
                style: AppTextStyles.section.copyWith(
                  color: context.colorTextPrimary,
                ),
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: l10n.settingsEditProfile,
            onTap: () => showEditProfileSheet(context),
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: l10n.settingsGoal,
            onTap: () => _showGoalSettings(context),
          ),
          _SettingsTile(
            icon: Icons.contrast_rounded,
            title: l10n.settingsTheme,
            value: _themeLabel(theme, l10n),
            onTap: () => _showOptionSheet<ThemePreference>(
              context,
              title: l10n.settingsTheme,
              subtitle: l10n.themeSubtitle,
              values: ThemePreference.values,
              selected: theme,
              labelOf: (value) => _themeLabel(value, l10n),
              onSelected: (value) => ref
                  .read(themePreferenceProvider.notifier)
                  .setPreference(value),
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: l10n.settingsLanguage,
            value: _languageLabel(language, l10n),
            onTap: () => _showOptionSheet<AppLocalePreference>(
              context,
              title: l10n.languageTitle,
              subtitle: l10n.languageSubtitle,
              values: AppLocalePreference.values,
              selected: language,
              labelOf: (value) => _languageLabel(value, l10n),
              onSelected: (value) =>
                  ref.read(languageProvider.notifier).setPreference(value),
            ),
          ),
          const Divider(height: 0, indent: 56),
          _SettingsTile(
            icon: Icons.auto_awesome_outlined,
            title: l10n.settingsAiStatus,
            onTap: () => _showAiStatus(context, ref),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: l10n.settingsExportData,
            onTap: () => _exportData(context, ref),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAppInfo,
            value: 'v1.0.0',
            onTap: () => _showAppInfo(context),
          ),
          _SettingsTile(
            icon: Icons.restart_alt_rounded,
            title: l10n.settingsResetData,
            destructive: true,
            onTap: () => _showResetConfirm(context, ref),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showGoalSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const GoalSettingsSheet(),
    );
  }

  static String _languageLabel(
    AppLocalePreference preference,
    AppLocalizations l10n,
  ) {
    return switch (preference) {
      AppLocalePreference.system => l10n.languageSystem,
      AppLocalePreference.korean => l10n.languageKorean,
      AppLocalePreference.english => l10n.languageEnglish,
    };
  }

  static String _themeLabel(ThemePreference preference, AppLocalizations l10n) {
    return switch (preference) {
      ThemePreference.system => l10n.themeSystem,
      ThemePreference.light => l10n.themeLight,
      ThemePreference.dark => l10n.themeDark,
    };
  }

  void _showOptionSheet<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<T> values,
    required T selected,
    required String Function(T value) labelOf,
    required Future<void> Function(T value) onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: AppTextStyles.headline.copyWith(
                    color: sheetContext.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.label.copyWith(
                    color: sheetContext.colorTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<T>(
                  groupValue: selected,
                  onChanged: (value) async {
                    if (value == null) return;
                    await onSelected(value);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  child: Column(
                    children: [
                      for (final value in values)
                        RadioListTile<T>(
                          value: value,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            labelOf(value),
                            style: AppTextStyles.body.copyWith(
                              color: sheetContext.colorTextPrimary,
                              fontWeight: value == selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final meals = ref.read(mealRecordsProvider);
    final weights = ref.read(weightRecordsProvider);
    final health = ref.read(dailyHealthProvider);

    final screenSize = MediaQuery.sizeOf(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
      'weight_records': weights.map((w) => w.toJson()).toList(),
      'meal_records': meals.map((m) => m.toJson()).toList(),
      'daily_health': health.toJson(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/sikdanscan_data_$timestamp.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.exportSubject,
        text: l10n.exportText,
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          screenSize.width,
          screenSize.height / 2,
        ),
      );
    } catch (_) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.exportFailed)),
      );
    }
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: context.l10n.brandName,
      applicationVersion: 'v1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/icons/app_icon.png', width: 48, height: 48),
      ),
      children: [
        Text(
          context.l10n.appInfoDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  /// User-facing availability of AI features. Proxy internals are shown only
  /// in debug builds.
  void _showAiStatus(BuildContext context, WidgetRef ref) {
    ref.invalidate(proxyConnectionStatusProvider);

    showDialog<void>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final proxyStatus = ref.watch(proxyConnectionStatusProvider);
          final l10n = context.l10n;
          final status = proxyStatus.valueOrNull;
          final loading = proxyStatus.isLoading;
          final available = status?.isConnected == true && !loading;

          return AlertDialog(
            title: Text(l10n.settingsAiStatus),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      loading
                          ? Icons.hourglass_top_rounded
                          : available
                          ? Icons.check_circle_rounded
                          : Icons.cloud_off_rounded,
                      color: loading
                          ? context.colorInfoText
                          : available
                          ? context.colorSuccessText
                          : context.colorWarningText,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loading
                          ? l10n.aiStatusChecking
                          : available
                          ? l10n.aiStatusAvailable
                          : l10n.aiStatusUnavailable,
                      style: AppTextStyles.section.copyWith(
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  available
                      ? l10n.aiStatusAvailableBody
                      : l10n.aiStatusUnavailableBody,
                  style: AppTextStyles.body.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
                if (kDebugMode && status != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.aiStatusDeveloperDetails,
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DebugStatusRow(
                    label: l10n.apiProxy,
                    ok: available,
                    iconAsset: null,
                  ),
                  _DebugStatusRow(
                    label: l10n.apiPublicFoodDb,
                    ok: available,
                    iconAsset: 'assets/icons/app/source_public_api.svg',
                  ),
                  _DebugStatusRow(
                    label: l10n.apiOpenAi,
                    ok: available,
                    iconAsset: 'assets/icons/app/source_ai.svg',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _proxyStatusMessage(l10n, status),
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => ref.invalidate(proxyConnectionStatusProvider),
                child: Text(l10n.apiRefresh),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.apiOk),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _proxyStatusMessage(
    AppLocalizations l10n,
    ProxyConnectionStatus status,
  ) {
    return switch (status.detail) {
      ProxyStatusDetail.notConfigured => l10n.proxyStatusNotConfigured,
      ProxyStatusDetail.connected => l10n.proxyStatusConnected,
      ProxyStatusDetail.unexpectedResponse =>
        l10n.proxyStatusUnexpectedResponse,
      ProxyStatusDetail.invalidToken => l10n.proxyStatusInvalidToken,
      ProxyStatusDetail.healthEndpointMissing => l10n.proxyStatusHealthMissing,
      ProxyStatusDetail.serverError => l10n.proxyStatusServerError,
      ProxyStatusDetail.unreachable => l10n.proxyStatusUnreachable,
    };
  }

  void _showResetConfirm(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: ctx.colorErrorText),
        title: Text(l10n.resetTitle),
        content: Text(l10n.resetMessage, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final resetFn = ref.read(dataResetProvider);
              await resetFn();
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(SnackBar(content: Text(l10n.resetDone)));
            },
            child: Text(l10n.resetAction),
          ),
        ],
      ),
    );
  }
}

class _DebugStatusRow extends StatelessWidget {
  const _DebugStatusRow({
    required this.label,
    required this.ok,
    required this.iconAsset,
  });

  final String label;
  final bool ok;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          if (iconAsset != null)
            AppSvgIcon(iconAsset!, color: context.colorTextSecondary, size: 15)
          else
            Icon(
              Icons.security_rounded,
              size: 15,
              color: context.colorTextSecondary,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextPrimary,
              ),
            ),
          ),
          Icon(
            ok ? Icons.check_circle : Icons.remove_circle_outline,
            size: 15,
            color: ok ? context.colorSuccessText : context.colorWarningText,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.destructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? value;
  final bool destructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.colorErrorText : null;
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: color ?? context.colorTextSecondary,
            size: 22,
          ),
          title: Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: color ?? context.colorTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: AppTextStyles.label.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTextTertiary,
                size: 20,
              ),
            ],
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (showDivider) const Divider(height: 0, indent: 56),
      ],
    );
  }
}
