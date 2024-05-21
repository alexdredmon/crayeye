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
import 'engine_notifier.dart'; // Import EngineNotifier
import 'utils.dart';
import 'add_engine_screen.dart'; // Import AddEngineScreen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PromptNotifier()),
        ChangeNotifierProvider(create: (context) => EngineNotifier()), // Add this line
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initUniLinks();
    _initEngines();
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

  Future<void> _initEngines() async {
    List<Map<String, String>> engines = await loadEngines();
    if (engines.isEmpty) {
      await saveEngines(defaultEngines);
    }
  }

  void _handleIncomingLink(String? link) {
    if (link != null && link.startsWith('crayeye://')) {
      Uri uri = Uri.parse(link);
      String? prompt = uri.queryParameters['prompt'];
      String? title = uri.queryParameters['title'];
      String? engineDefinition = uri.queryParameters['engine'];

      if (prompt != null && title != null) {
        Provider.of<PromptNotifier>(context, listen: false)
          .setPromptAndTitle(prompt, title);
      } else if (engineDefinition != null && title != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddEngineScreen(
                onSave: (newEngine) async {
                  List<Map<String, String>> engines = await loadEngines();
                  engines.add(newEngine);
                  await saveEngines(engines);
                },
                initialTitle: title,
                initialDefinition: engineDefinition,
              ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      navigatorKey: navigatorKey,
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
