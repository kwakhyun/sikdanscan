import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/chat_message.dart';
import '../../../l10n/app_localizations_context.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final VoidCallback? onRetry;

  const ChatBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isError = message.type == ChatMessageType.error;
    final l10n = context.l10n;
    final content = isError ? l10n.chatTemporaryError : message.content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && showAvatar) ...[
            const CoachAvatar(),
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: isError ? null : () => _copy(context, content),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primaryStrong
                      : isError
                      ? AppColors.error.withValues(alpha: 0.08)
                      : context.colorSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: isError
                              ? AppColors.error.withValues(alpha: 0.35)
                              : context.colorBorder,
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChatMessageText(content: content, isUser: isUser),
                    if (isError && onRetry != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(l10n.chatRetry),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.type == ChatMessageType.offline) ...[
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 12,
                            color: context.colorTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.chatOfflineAnswer,
                            style: AppTextStyles.micro.copyWith(
                              color: context.colorTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          AppFormat.time(message.timestamp),
                          style: AppTextStyles.micro.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.85)
                                : context.colorTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.chatCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _ChatMessageText extends StatelessWidget {
  const _ChatMessageText({required this.content, required this.isUser});

  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: isUser ? Colors.white : context.colorTextPrimary,
    );

    if (isUser || !content.contains('**')) {
      return Text(content, style: baseStyle);
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: _boldMarkdownSpans(content)),
    );
  }
}

List<TextSpan> _boldMarkdownSpans(String text) {
  final spans = <TextSpan>[];
  var cursor = 0;

  while (cursor < text.length) {
    final start = text.indexOf('**', cursor);
    if (start == -1) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }

    if (start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, start)));
    }

    final end = text.indexOf('**', start + 2);
    if (end == -1) {
      spans.add(TextSpan(text: text.substring(start).replaceAll('**', '')));
      break;
    }

    final boldText = text.substring(start + 2, end);
    if (boldText.isNotEmpty) {
      spans.add(
        TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
    }
    cursor = end + 2;
  }

  return spans;
}
