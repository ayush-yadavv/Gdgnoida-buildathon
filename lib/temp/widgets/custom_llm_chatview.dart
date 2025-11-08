import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CustomLlmChatView extends StatelessWidget {
  const CustomLlmChatView({
    super.key,
    required this.provider,
    required this.suggestions,
    required this.welcomeMessage,
  });

  final LlmProvider provider;
  final List<String> suggestions;
  final String welcomeMessage;

  @override
  Widget build(BuildContext context) {
    return LlmChatView(
      provider: provider,
      cancelMessage: "Ops!",
      suggestions: suggestions,
      errorMessage: "Ops! Something went wrong.",
      welcomeMessage: welcomeMessage,
      // "👋 Hello, what would you like to know about ${controller.currentItemName.value}? 🍽️",
      style: LlmChatViewStyle(
        stopButtonStyle: ActionButtonStyle(
          icon: Iconsax.stop,
          iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        copyButtonStyle: ActionButtonStyle(
          icon: Iconsax.copy,

          iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
        actionButtonBarDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        menuColor: Theme.of(context).colorScheme.surface,
        addButtonStyle: ActionButtonStyle(
          // icon: Iconsax.attach_circle,
          iconDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
          iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        submitButtonStyle: ActionButtonStyle(
          icon: Iconsax.send_1_copy,
          iconDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
          iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        suggestionStyle: SuggestionStyle(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            // color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        userMessageStyle: UserMessageStyle(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        llmMessageStyle: LlmMessageStyle(
          markdownStyle:
              MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                  as MarkdownStyleSheet?,
          icon: Icons.auto_awesome,
          iconColor: Theme.of(context).colorScheme.primary,
          iconDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chatInputStyle: ChatInputStyle(
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        fileAttachmentStyle: FileAttachmentStyle(
          icon: Iconsax.attach_circle_copy,
        ),
        recordButtonStyle: ActionButtonStyle(icon: Iconsax.microphone),
      ),
    );
  }
}
