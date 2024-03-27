import 'package:flutter/material.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitten Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          background: Colors.blueGrey.shade800,
          onBackground: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kitten Scan'),
    );
  }
}
