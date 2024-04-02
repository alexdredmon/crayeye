// FILENAME: prompt_dialogs.dart

import 'package:flutter/material.dart';

void showAddPromptDialog(BuildContext context, Function(String, String) onSave, {String? initialPrompt, String?initialTitle}) {
  String newTitle = initialTitle ?? '';
  String newPrompt = initialPrompt ?? '';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Add Prompt',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: newTitle),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: (value) {
                newTitle = value;
              },
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Prompt',
                labelStyle: TextStyle(color: Colors.white),
              ),
              maxLines: 3,
              controller: TextEditingController(text: newPrompt),
              onChanged: (value) {
                newPrompt = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(newTitle, newPrompt);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void showEditPromptDialog(
  BuildContext context,
  int index,
  String currentTitle,
  String currentPrompt,
  Function(int, String, String) onSave,
) {
  String updatedTitle = currentTitle;
  String updatedPrompt = currentPrompt;
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Text(
          'Edit Prompt',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              controller: TextEditingController(text: updatedTitle),
              onChanged: (value) {
                updatedTitle = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Prompt',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: 3,
              controller: TextEditingController(text: updatedPrompt),
              onChanged: (value) {
                updatedPrompt = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(index, updatedTitle, updatedPrompt);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
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
