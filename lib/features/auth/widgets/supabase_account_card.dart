import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import 'supabase_auth_sheet.dart';

class SupabaseAccountCard extends ConsumerWidget {
  const SupabaseAccountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configured = ref.watch(supabaseConfiguredProvider);
    final userState = ref.watch(supabaseUserProvider);
    final authState = ref.watch(supabaseAuthControllerProvider);
    final user = userState.valueOrNull;
    final isLoading = authState.isLoading;

    final title = !configured
        ? context.l10n.authCloudNotConfiguredTitle
        : user == null
        ? context.l10n.authCloudSignedOutTitle
        : context.l10n.authCloudSignedInTitle;
    final subtitle = !configured
        ? context.l10n.authCloudNotConfiguredSubtitle
        : user == null
        ? context.l10n.authCloudSignedOutSubtitle
        : (user.email ?? context.l10n.authCloudSignedInSubtitle);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: configured
              ? AppColors.primary.withValues(alpha: 0.22)
              : context.colorBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: configured
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : context.colorSurfaceVariant,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  user == null
                      ? Icons.cloud_queue_rounded
                      : Icons.cloud_done_rounded,
                  color: configured
                      ? AppColors.primary
                      : context.colorTextTertiary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.colorTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.42,
                        fontWeight: FontWeight.w600,
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (configured) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (user == null)
                  Expanded(
                    child: _AccountActionButton(
                      label: context.l10n.authSignInOrSignUp,
                      icon: Icons.login_rounded,
                      onPressed: isLoading
                          ? null
                          : () => _showAuthSheet(context),
                    ),
                  )
                else ...[
                  Expanded(
                    child: _AccountActionButton(
                      label: context.l10n.authSyncNow,
                      icon: Icons.sync_rounded,
                      onPressed: isLoading ? null : () => _sync(context, ref),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AccountActionButton(
                      label: context.l10n.authSignOut,
                      icon: Icons.logout_rounded,
                      outlined: true,
                      onPressed: isLoading
                          ? null
                          : () => _signOut(context, ref),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAuthSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SupabaseAuthSheet(),
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(supabaseAuthControllerProvider.notifier)
          .syncLocalToRemote();
      if (!context.mounted) return;
      _showMessage(context, context.l10n.authSyncDone);
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, context.l10n.authFailed);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(supabaseAuthControllerProvider.notifier).signOut();
      if (!context.mounted) return;
      _showMessage(context, context.l10n.authSignOutDone);
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, context.l10n.authFailed);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _AccountActionButton extends StatelessWidget {
  const _AccountActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: context.colorTextPrimary,
            side: BorderSide(color: context.colorBorder),
            shape: shape,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: shape,
        ),
        child: child,
      ),
    );
  }
}
