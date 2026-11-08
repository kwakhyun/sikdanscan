import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/ai_chat_service.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/ai_consent_sheet.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/suggestion_chips.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || ref.read(chatLoadingProvider)) return;
    // Personal data goes to the AI provider only after explicit consent;
    // without it the coach answers with the built-in tips.
    if (ref.read(aiChatServiceProvider).isConfigured &&
        !ref.read(aiDataConsentProvider) &&
        !ref.read(aiConsentAutoPromptedProvider)) {
      ref.read(aiConsentAutoPromptedProvider.notifier).state = true;
      await ensureAiConsent(context, ref);
      if (!mounted) return;
    }
    ref.read(chatMessagesProvider.notifier).send(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showClearChatDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatClearTitle),
        content: Text(l10n.chatClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: ctx.colorErrorText),
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: Text(l10n.chatClearAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);
    final status = ref.watch(chatStatusProvider);
    final l10n = context.l10n;
    final hasUserMessages = messages.any((m) => m.isUser);
    final welcome = ChatMessage(
      id: 'welcome',
      content: l10n.chatWelcome,
      isUser: false,
      timestamp: messages.isEmpty ? DateTime.now() : messages.first.timestamp,
    );
    final items = [welcome, ...messages];

    ref.listen(chatMessagesProvider, (prev, next) => _scrollToBottom());

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const CoachAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.chatTitle, style: AppTextStyles.section),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLoading
                              ? AppColors.secondary
                              : switch (status) {
                                  CoachConnection.online ||
                                  CoachConnection.unknown => AppColors.success,
                                  CoachConnection.limited ||
                                  CoachConnection.error => AppColors.warning,
                                  CoachConnection.offline ||
                                  CoachConnection.needsConsent =>
                                    context.colorTextTertiary,
                                },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          isLoading
                              ? l10n.chatTyping
                              : switch (status) {
                                  CoachConnection.online ||
                                  CoachConnection.unknown =>
                                    l10n.chatStatusOnline,
                                  CoachConnection.limited =>
                                    l10n.chatStatusLimited,
                                  CoachConnection.error => l10n.chatStatusError,
                                  CoachConnection.offline =>
                                    l10n.chatStatusOffline,
                                  CoachConnection.needsConsent =>
                                    l10n.chatStatusNeedsConsent,
                                },
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.micro.copyWith(
                            color: context.colorTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.chatClearTitle,
            onPressed: messages.isEmpty || isLoading
                ? null
                : () => _showClearChatDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (status == CoachConnection.offline ||
              status == CoachConnection.limited ||
              status == CoachConnection.needsConsent)
            Container(
              width: double.infinity,
              color: context.colorSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    status == CoachConnection.needsConsent
                        ? Icons.privacy_tip_outlined
                        : Icons.cloud_off_rounded,
                    size: 18,
                    color: context.colorTextSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      switch (status) {
                        CoachConnection.limited => l10n.chatLimitedBanner,
                        CoachConnection.needsConsent =>
                          l10n.aiConsentChatBanner,
                        _ => l10n.chatOfflineBanner,
                      },
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ),
                  if (status == CoachConnection.needsConsent)
                    TextButton(
                      onPressed: () => ensureAiConsent(context, ref),
                      child: Text(l10n.aiConsentSearchAction),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == items.length) return const TypingIndicator();
                final message = items[index];
                final isLast = index == items.length - 1;
                return ChatBubble(
                  message: message,
                  showAvatar:
                      !message.isUser &&
                      (index == 0 || items[index - 1].isUser),
                  onRetry: isLast && message.type == ChatMessageType.error
                      ? () =>
                            ref.read(chatMessagesProvider.notifier).retryLast()
                      : null,
                );
              },
            ),
          ),
          if (!hasUserMessages) SuggestionChips(onSuggestionTap: _sendMessage),
          _buildInputBar(isLoading),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isLoading) {
    final l10n = context.l10n;
    final canSend = _controller.text.trim().isNotEmpty && !isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.colorSurface,
        border: Border(top: BorderSide(color: context.colorBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                maxLength: AiChatService.maxMessageLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                // Show the counter only close to the limit.
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => maxLength != null && currentLength > maxLength - 100
                    ? Text('$currentLength/$maxLength')
                    : null,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.colorPrimaryText,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: l10n.chatSend,
              onPressed: canSend ? () => _sendMessage(_controller.text) : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryStrong,
                foregroundColor: Colors.white,
                minimumSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
