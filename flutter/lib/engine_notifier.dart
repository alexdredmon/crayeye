// FILENAME: engine_notifier.dart
import 'package:flutter/material.dart';

class EngineNotifier extends ChangeNotifier {
  Map<String, String> _engine = {
    'id': '',
    'title': '',
    'definition': '',
  };

  Map<String, String> get engine => _engine;

  void setEngine(Map<String, String> newEngine) {
    _engine = newEngine;
    notifyListeners();
  }

  void updateEngineTitle(String title) {
    _engine['title'] = title;
    notifyListeners();
  }

  void updateEngineDefinition(String definition) {
    _engine['definition'] = definition;
    notifyListeners();
  }
}
// eof
