import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const ChatBubble({super.key, required this.message, this.showAvatar = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && showAvatar) ...[
            Container(
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
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : context.colorSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser ? null : Border.all(color: context.colorBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChatMessageText(content: message.content, isUser: isUser),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : context.colorTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  return spans.isEmpty ? [TextSpan(text: text)] : spans;
}
