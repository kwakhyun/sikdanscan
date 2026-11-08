import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import 'sheet_handle.dart';

/// Returns whether AI features may send the user's data, asking once with a
/// disclosure sheet (what is sent, to whom, how to withdraw) when the user
/// has not decided yet.
Future<bool> ensureAiConsent(BuildContext context, WidgetRef ref) async {
  if (ref.read(aiDataConsentProvider)) return true;
  final notifier = ref.read(aiDataConsentProvider.notifier);
  final agreed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AiConsentSheet(),
  );
  if (agreed != true) return false;
  try {
    await notifier.setValue(true);
  } catch (_) {
    return false;
  }
  return true;
}

/// Opens the configured privacy policy in the browser.
Future<void> openPrivacyPolicy() async {
  final uri = AppLinks.privacyPolicy;
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _AiConsentSheet extends StatelessWidget {
  const _AiConsentSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPolicy = AppLinks.privacyPolicy != null;

    Widget item(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colorPrimaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: context.colorTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                l10n.aiConsentTitle,
                style: AppTextStyles.title.copyWith(
                  color: context.colorTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.aiConsentIntro,
              style: AppTextStyles.body.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            item(Icons.photo_camera_outlined, l10n.aiConsentItemPhoto),
            item(Icons.restaurant_menu_rounded, l10n.aiConsentItemMeals),
            item(Icons.chat_bubble_outline_rounded, l10n.aiConsentItemChat),
            const SizedBox(height: 6),
            Text(
              l10n.aiConsentRevokeNote,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
            if (hasPolicy) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: openPrivacyPolicy,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(l10n.settingsPrivacyPolicy),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.aiConsentAgree),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.aiConsentDecline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
