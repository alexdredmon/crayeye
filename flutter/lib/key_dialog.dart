// key_dialog.dart
// key_dialog.dart
import 'package:flutter/material.dart';
import 'config.dart';

void showKeyDialog(BuildContext context) {
  String openAIKey = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'OpenAI Key',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          onChanged: (value) {
            openAIKey = value;
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your OpenAI API key',
            hintStyle: TextStyle(color: Colors.white),
            labelText: 'OpenAI API Key',
            labelStyle: TextStyle(color: Colors.white),
          ),
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
            onPressed: () async {
              await saveOpenAIKey(openAIKey);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

// eof
