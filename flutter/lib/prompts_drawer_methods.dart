// FILENAME: prompts_drawer_methods.dart
import 'package:flutter/material.dart';
import 'prompt_dialogs.dart';
import 'config.dart';

class PromptsDrawerMethods {
  static void reorderPrompts({
    required List<Map<String, String>> prompts,
    required int oldIndex,
    required int newIndex,
    required Function(List<Map<String, String>>, String) onPromptsUpdated,
  }) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = prompts.removeAt(oldIndex);
    prompts.insert(newIndex, item);
    onPromptsUpdated(prompts, prompts[newIndex]['id']!);
  }

  static void editPrompt({
    required BuildContext context,
    required List<Map<String, String>> prompts,
    required String uuid,
    required Function(List<Map<String, String>>, String) onPromptsUpdated,
    required String selectedPromptUuid,
  }) {
    final promptIndex = prompts.indexWhere((prompt) => prompt['id'] == uuid);
    showEditPromptDialog(
      context,
      uuid,
      prompts[promptIndex]['title']!,
      prompts[promptIndex]['prompt']!,
      (promptId, title, prompt) {
        prompts[promptIndex]['title'] = title;
        prompts[promptIndex]['prompt'] = prompt;
        onPromptsUpdated(prompts, selectedPromptUuid);
      },
    );
  }

  static void deletePrompt({
    required List<Map<String, String>> prompts,
    required String uuid,
    required Function(List<Map<String, String>>, String) onPromptsUpdated,
    required String selectedPromptUuid,
  }) {
    final promptIndex = prompts.indexWhere((prompt) => prompt['id'] == uuid);
    prompts.removeAt(promptIndex);
    if (selectedPromptUuid == uuid) {
      selectedPromptUuid = prompts.isNotEmpty ? prompts.first['id']! : '';
    }
    onPromptsUpdated(prompts, selectedPromptUuid);
  }

  static void addPrompt({
    required BuildContext context,
    required List<Map<String, String>> prompts,
    required Function(List<Map<String, String>>, String) onPromptsUpdated,
    required String selectedPromptUuid,
  }) {
    showAddPromptDialog(
      context,
      (title, prompt, _) {
        String newPromptId = uuid.v4(); // Generate the UUID here
        prompts.add({'id': newPromptId, 'title': title, 'prompt': prompt});
        onPromptsUpdated(prompts, selectedPromptUuid);
      },
    );
  }

  static void resetPrompts({
    required List<Map<String, String>> prompts,
    required Function(List<Map<String, String>>, String) onPromptsUpdated,
  }) {
    prompts.clear();
    prompts.addAll(defaultPrompts);
    onPromptsUpdated(prompts, prompts.first['id']!);
  }
}
// eof
