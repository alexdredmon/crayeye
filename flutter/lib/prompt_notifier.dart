// FILENAME: prompt_notifier.dart
import 'package:flutter/material.dart';

class PromptNotifier extends ChangeNotifier {
  String? _prompt;

  String? get prompt => _prompt;

  void setPrompt(String? newPrompt) {
    _prompt = newPrompt;
    notifyListeners();
  }
}
// eof
