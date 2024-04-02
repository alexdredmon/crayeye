// FILENAME: prompts_drawer_methods.dart
import 'package:flutter/material.dart';
import 'prompt_dialogs.dart';
import 'config.dart';


class PromptsDrawerMethods {
  static void reorderPrompts({
    required List<Map<String, String>> prompts,
    required int oldIndex,
    required int newIndex,
    required Function(List<Map<String, String>>, int) onPromptsUpdated,
  }) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = prompts.removeAt(oldIndex);
    prompts.insert(newIndex, item);
    onPromptsUpdated(prompts, newIndex);
  }

  static void editPrompt({
    required BuildContext context,
    required List<Map<String, String>> prompts,
    required int index,
    required Function(List<Map<String, String>>, int) onPromptsUpdated,
    required int selectedPromptIndex,
  }) {
    showEditPromptDialog(
      context,
      index,
      prompts[index]['title']!,
      prompts[index]['prompt']!,
      (index, title, prompt) {
        prompts[index]['title'] = title;
        prompts[index]['prompt'] = prompt;
        onPromptsUpdated(prompts, selectedPromptIndex);
      },
    );
  }

  static void deletePrompt({
    required List<Map<String, String>> prompts,
    required int index,
    required Function(List<Map<String, String>>, int) onPromptsUpdated,
    required int selectedPromptIndex,
  }) {
    prompts.removeAt(index);
    if (selectedPromptIndex >= prompts.length) {
      selectedPromptIndex = prompts.length - 1;
    }
    onPromptsUpdated(prompts, selectedPromptIndex);
  }

  static void addPrompt({
    required BuildContext context,
    required List<Map<String, String>> prompts,
    required Function(List<Map<String, String>>, int) onPromptsUpdated,
    required int selectedPromptIndex,
  }) {
    showAddPromptDialog(
      context,
      (title, prompt) {
        prompts.add({'title': title, 'prompt': prompt});
        onPromptsUpdated(prompts, selectedPromptIndex);
      },
    );
  }

  static void resetPrompts({
    required List<Map<String, String>> prompts,
    required Function(List<Map<String, String>>, int) onPromptsUpdated,
  }) {
    prompts.clear();
    prompts.addAll(defaultPrompts);
    onPromptsUpdated(prompts, 0);
  }
}
// eof
