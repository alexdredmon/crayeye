// FILENAME: main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config.dart';
import 'package:uni_links/uni_links.dart';
import 'home_page.dart';
import 'prompt_dialogs.dart';
import 'package:provider/provider.dart';
import 'prompt_notifier.dart'; // Make sure to import PromptNotifier
import 'utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => PromptNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Get the initial link
    String? initialLink = await getInitialLink();
    _handleIncomingLink(initialLink);

    // Listen for incoming links
    uriLinkStream.listen((Uri? uri) {
      _handleIncomingLink(uri.toString());
    }, onError: (err) {
      // Handle errors
    });
  }

  void _handleIncomingLink(String? link) {
    if (link != null && link.startsWith('crayeye://')) {
      Uri uri = Uri.parse(link);
      String? prompt = uri.queryParameters['prompt'];
      String? title = uri.queryParameters['title']; // Get the title parameter
      if (prompt != null && title != null) {
        Provider.of<PromptNotifier>(context, listen: false)
          .setPromptAndTitle(prompt, title);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'CrayEye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          background: Colors.black,
          onBackground: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'CrayEye'),
    );
  }
}
// eof
