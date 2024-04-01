// FILENAME: main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config.dart';
import 'package:uni_links/uni_links.dart';
import 'home_page.dart';
import 'prompt_dialogs.dart'; // Import the file containing showAddPromptDialog

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialPrompt;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Get the initial link
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleIncomingLink(initialLink);
    }

    // Listen for incoming links
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleIncomingLink(uri.toString());
      }
    }, onError: (err) {
      // Handle errors
    });
  }

  void _handleIncomingLink(String link) {
    if (link.startsWith('crayeye://')) {
      Uri uri = Uri.parse(link);
      String? prompt = uri.queryParameters['prompt'];
      if (prompt != null) {
        setState(() {
          _initialPrompt = prompt.replaceAll('+', ' ');
        });
      }
    }
  }

  void _showAddPromptDialog(BuildContext context) {
    showAddPromptDialog(
      context,
      (title, prompt) {
        // Handle saving the prompt
      },
      initialPrompt: _initialPrompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrayEye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          background: Colors.blueGrey.shade800,
          onBackground: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'CrayEye', initialPrompt: _initialPrompt),
    );
  }
}
// eof
