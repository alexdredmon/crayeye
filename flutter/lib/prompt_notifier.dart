// FILENAME: prompt_notifier.dart
import 'package:flutter/material.dart';

class PromptNotifier extends ChangeNotifier {
  String? _prompt;
  String? _title; // Add a title field

  String? get prompt => _prompt;
  String? get title => _title; // Add a getter for title

  void setPromptAndTitle(String? newPrompt, String? newTitle) {
    _prompt = newPrompt;
    _title = newTitle; // Set the title
    notifyListeners();
  }
}
// eof
