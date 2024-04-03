// FILENAME: response_notifier.dart
import 'package:flutter/foundation.dart';

class ResponseNotifier extends ChangeNotifier {
  String _response = '';

  String get response => _response;

  void updateResponse(String newResponse) {
    _response = newResponse;
    notifyListeners();
  }

  void clearResponse() {
    _response = '';
    notifyListeners();
  }
}

//eof
