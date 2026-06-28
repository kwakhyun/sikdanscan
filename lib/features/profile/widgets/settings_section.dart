import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/proxy_status_service.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_svg_icon.dart';
import 'edit_profile_sheet.dart';
import 'goal_settings_sheet.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final darkMode = ref.watch(darkModeProvider);
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
            child: Text(
              l10n.settingsTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colorTextPrimary,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: l10n.settingsEditProfile,
            onTap: () => _showEditProfile(context),
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: l10n.settingsGoal,
            onTap: () => _showGoalSettings(context),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.settingsNotifications,
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (_) =>
                  ref.read(notificationsEnabledProvider.notifier).toggle(),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () =>
                ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.settingsDarkMode,
            trailing: Switch(
              value: darkMode,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
              activeThumbColor: AppColors.primary,
            ),
            onTap: () => ref.read(darkModeProvider.notifier).toggle(),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: l10n.settingsLanguage,
            trailing: Text(
              _languageLabel(language, l10n),
              style: TextStyle(fontSize: 14, color: context.colorTextTertiary),
            ),
            onTap: () => _showLanguageSettings(context, ref),
          ),
          const Divider(height: 0, indent: 56),
          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: l10n.settingsApiStatus,
            onTap: () => _showApiStatus(context, ref),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: l10n.settingsExportData,
            onTap: () => _exportData(context, ref),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAppInfo,
            trailing: Text(
              'v1.0.0',
              style: TextStyle(fontSize: 14, color: context.colorTextTertiary),
            ),
            onTap: () => _showAppInfo(context),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.settingsResetData,
            color: AppColors.error,
            onTap: () => _showResetConfirm(context, ref),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const EditProfileSheet(),
    );
  }

  void _showGoalSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const GoalSettingsSheet(),
    );
  }

  String _languageLabel(AppLocalePreference preference, AppLocalizations l10n) {
    return switch (preference) {
      AppLocalePreference.system => l10n.languageSystem,
      AppLocalePreference.korean => l10n.languageKorean,
      AppLocalePreference.english => l10n.languageEnglish,
    };
  }

  void _showLanguageSettings(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(languageProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.languageTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.colorTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.languageSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colorTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final preference in AppLocalePreference.values)
                      _LanguageOptionTile(
                        label: _languageLabel(preference, l10n),
                        selected: selected == preference,
                        onTap: () async {
                          await ref
                              .read(languageProvider.notifier)
                              .setPreference(preference);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final meals = ref.read(mealRecordsProvider);
    final weights = ref.read(weightRecordsProvider);
    final health = ref.read(dailyHealthProvider);

    // async 전에 context 의존 값 캡처
    final screenSize = MediaQuery.of(context).size;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final exportSubject = context.l10n.exportSubject;
    final exportText = context.l10n.exportText;
    final exportFailed = context.l10n.exportFailed;

    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'profile': profile.toJson(),
      'weight_records': weights.map((w) => w.toJson()).toList(),
      'meal_records': meals.map((m) => m.toJson()).toList(),
      'daily_health': health.toJson(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    try {
      // 임시 디렉토리에 JSON 파일 저장 후 공유
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/sikdanscan_data_$timestamp.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: exportSubject,
        text: exportText,
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          screenSize.width,
          screenSize.height / 2,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$exportFailed: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  void _showApiStatus(BuildContext context, WidgetRef ref) {
    ref.invalidate(proxyConnectionStatusProvider);

    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final proxyStatus = ref.watch(proxyConnectionStatusProvider);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.settingsApiStatus,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            content: proxyStatus.when(
              data: (status) => _buildApiStatusContent(context, status),
              loading: () => _buildApiStatusContent(
                context,
                ProxyConnectionStatus.unavailable(
                  message: context.l10n.apiChecking,
                ),
                loading: true,
              ),
              error: (_, __) => _buildApiStatusContent(
                context,
                ProxyConnectionStatus.unavailable(
                  message: context.l10n.apiCheckFailed,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => ref.invalidate(proxyConnectionStatusProvider),
                child: Text(context.l10n.apiRefresh),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.apiOk),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildApiStatusContent(
    BuildContext context,
    ProxyConnectionStatus status, {
    bool loading = false,
  }) {
    final proxyConnected = status.isConnected && !loading;
    final proxyLabel = _proxyStatusLabel(context, status, loading: loading);
    final dependentLabel = proxyConnected
        ? context.l10n.apiConnected
        : context.l10n.apiProxyRequired;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildApiStatusRow(
          context,
          context.l10n.apiBuiltInDb,
          true,
          iconAsset: 'assets/icons/app/source_local_db.svg',
        ),
        _buildApiStatusRow(
          context,
          context.l10n.apiProxy,
          proxyConnected,
          statusLabel: proxyLabel,
          loading: loading,
          leadingIcon: Icons.security_rounded,
        ),
        _buildApiStatusRow(
          context,
          context.l10n.apiPublicFoodDb,
          proxyConnected,
          statusLabel: dependentLabel,
          iconAsset: 'assets/icons/app/source_public_api.svg',
        ),
        _buildApiStatusRow(
          context,
          context.l10n.apiOpenAi,
          proxyConnected,
          statusLabel: dependentLabel,
          iconAsset: 'assets/icons/app/source_ai.svg',
        ),
        _buildApiStatusRow(
          context,
          context.l10n.apiBarcode,
          true,
          iconAsset: 'assets/icons/app/source_barcode.svg',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${status.message}\n${context.l10n.apiSecurityNote}',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: context.colorTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _proxyStatusLabel(
    BuildContext context,
    ProxyConnectionStatus status, {
    required bool loading,
  }) {
    if (loading) return context.l10n.apiCheckingShort;

    switch (status.state) {
      case ProxyConnectionState.connected:
        return context.l10n.apiConnected;
      case ProxyConnectionState.notConfigured:
        return context.l10n.apiNotConfigured;
      case ProxyConnectionState.unavailable:
        return context.l10n.apiOffline;
    }
  }

  Widget _buildApiStatusRow(
    BuildContext context,
    String label,
    bool connected, {
    String? statusLabel,
    bool loading = false,
    String? iconAsset,
    IconData? leadingIcon,
  }) {
    final color = loading
        ? Colors.blue
        : connected
        ? Colors.green
        : Colors.orange;
    final icon = loading
        ? Icons.hourglass_top_rounded
        : connected
        ? Icons.check_circle
        : Icons.warning_amber_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            AppSvgIcon(iconAsset, color: context.colorTextSecondary, size: 17),
            const SizedBox(width: 8),
          ] else if (leadingIcon != null) ...[
            Icon(leadingIcon, color: context.colorTextSecondary, size: 17),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  statusLabel ??
                      (connected
                          ? context.l10n.apiConnected
                          : context.l10n.apiNotConfigured),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(context.l10n.resetTitle),
          ],
        ),
        content: Text(context.l10n.resetMessage, style: TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final resetFn = ref.read(dataResetProvider);
              await resetFn();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.resetDone),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text(context.l10n.resetAction),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : context.colorTextTertiary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: context.colorTextPrimary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? color;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.color,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color ?? context.colorTextPrimary,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTextTertiary,
                size: 20,
              ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (showDivider) const Divider(height: 0, indent: 56),
      ],
    );
  }
}
