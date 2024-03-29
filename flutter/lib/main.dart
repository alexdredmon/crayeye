// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}
// eof
