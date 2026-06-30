import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';

class SupabaseAuthSheet extends ConsumerStatefulWidget {
  const SupabaseAuthSheet({super.key});

  @override
  ConsumerState<SupabaseAuthSheet> createState() => _SupabaseAuthSheetState();
}

class _SupabaseAuthSheetState extends ConsumerState<SupabaseAuthSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isSignUp = false;
  bool _oauthInProgress = false;
  String? _lastMergedOAuthUserId;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = ref.read(userProfileProvider).displayName;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(supabaseUserProvider, (previous, next) {
      final user = next.valueOrNull;
      if (!_oauthInProgress ||
          user == null ||
          user.id == _lastMergedOAuthUserId) {
        return;
      }

      _oauthInProgress = false;
      _lastMergedOAuthUserId = user.id;
      unawaited(_completeOAuthSignIn());
    });

    final authState = ref.watch(supabaseAuthControllerProvider);
    final isLoading = authState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 18,
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
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _isSignUp
                  ? context.l10n.authSignUpTitle
                  : context.l10n.authSignInTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.authSheetSubtitle,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colorSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _ModeButton(
                    label: context.l10n.authSignIn,
                    selected: !_isSignUp,
                    onTap: isLoading
                        ? null
                        : () => setState(() => _isSignUp = false),
                  ),
                  _ModeButton(
                    label: context.l10n.authSignUp,
                    selected: _isSignUp,
                    onTap: isLoading
                        ? null
                        : () => setState(() => _isSignUp = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_isSignUp) ...[
              _AuthTextField(
                label: context.l10n.authDisplayName,
                controller: _displayNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
            ],
            _AuthTextField(
              label: context.l10n.authEmail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 12),
            _AuthTextField(
              label: context.l10n.authPassword,
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => isLoading ? null : _submit(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.45,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isSignUp
                            ? context.l10n.authSubmitSignUp
                            : context.l10n.authSubmitSignIn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            _AuthDivider(label: context.l10n.authSocialDivider),
            const SizedBox(height: 14),
            _SocialLoginButton(
              label: context.l10n.authContinueWithKakao,
              icon: Icons.chat_bubble_rounded,
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: const Color(0xFF191919),
              onPressed: isLoading
                  ? null
                  : () => _submitOAuth(SocialLoginProvider.kakao),
            ),
            const SizedBox(height: 10),
            _SocialLoginButton(
              label: context.l10n.authContinueWithGoogle,
              icon: Icons.g_mobiledata_rounded,
              backgroundColor: Colors.white,
              foregroundColor: context.colorTextPrimary,
              borderColor: context.colorBorder,
              onPressed: isLoading
                  ? null
                  : () => _submitOAuth(SocialLoginProvider.google),
            ),
            const SizedBox(height: 10),
            _SocialLoginButton(
              label: context.l10n.authContinueWithApple,
              icon: Icons.apple,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              onPressed: isLoading
                  ? null
                  : () => _submitOAuth(SocialLoginProvider.apple),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    _oauthInProgress = false;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.length < 8) {
      _showMessage(context.l10n.authInvalidInput);
      return;
    }

    try {
      final controller = ref.read(supabaseAuthControllerProvider.notifier);
      if (_isSignUp) {
        await controller.signUp(
          email: email,
          password: password,
          displayName: _displayNameController.text.trim(),
        );
      } else {
        await controller.signIn(email: email, password: password);
      }

      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(
        _isSignUp ? context.l10n.authSignUpDone : context.l10n.authSignInDone,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.authFailed);
    }
  }

  Future<void> _submitOAuth(SocialLoginProvider provider) async {
    _oauthInProgress = true;
    try {
      final launched = await ref
          .read(supabaseAuthControllerProvider.notifier)
          .signInWithOAuth(provider);
      if (!mounted) return;
      if (!launched) {
        _oauthInProgress = false;
        _showMessage(context.l10n.authFailed);
        return;
      }
      _showMessage(context.l10n.authOAuthStarted);
    } catch (_) {
      _oauthInProgress = false;
      if (!mounted) return;
      _showMessage(context.l10n.authFailed);
    }
  }

  Future<void> _completeOAuthSignIn() async {
    try {
      await ref
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(context.l10n.authOAuthDone);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.authFailed);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colorBorder, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colorTextTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colorBorder, height: 1)),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.45),
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? context.colorSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.primary : context.colorTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.colorTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
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
}
