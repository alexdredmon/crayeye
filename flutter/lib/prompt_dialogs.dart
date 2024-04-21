// FILENAME: prompt_dialogs.dart
import 'package:flutter/material.dart';
import 'add_prompt_screen.dart';
import 'edit_prompt_screen.dart';

void showAddPromptDialog(BuildContext context, Function(String, String, String) onSave, {String? initialPrompt, String? initialTitle}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddPromptScreen(onSave: onSave, initialPrompt: initialPrompt, initialTitle: initialTitle),
      fullscreenDialog: true,
    ),
  );
}

void showEditPromptDialog(
  BuildContext context,
  String promptId,
  String currentTitle,
  String currentPrompt,
  Function(String, String, String) onSave,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditPromptScreen(
        promptId: promptId,
        currentTitle: currentTitle,
        currentPrompt: currentPrompt,
        onSave: onSave,
      ),
      fullscreenDialog: true,
    ),
  );
}

Future<bool> showDeletePromptConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Delete Prompt",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete this prompt?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}

Future<bool> showResetPromptsConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Reset Prompts",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to reset all prompts to default?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text("Reset"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
// eof
