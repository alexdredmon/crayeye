const String baseUrl = 'https://example';
// config.dart

import 'package:shared_preferences/shared_preferences.dart';

const String OPENAI_API_KEY = 'example';
List<Map<String, String>> defaultPrompts = [
  {'title': 'Describe image', 'prompt': 'Describe this image'},
  {'title': 'Keyword extraction ', 'prompt': 'Analyze the following scene and return only a list of keywords for items/concepts you find in the scene.  Keywords should be separated by commas and ordered by their relevance to the scene.  Return nothing but these keywords, say nothing else in your response.'},
  {'title': 'Bizarro world', 'prompt': 'Let\' play a fun game:  Craft a creative narrative describing the origin or details of the scene before you but do not base it in reality - pretend you are in a "bizarro world" where everything is the opposite of what it actually is while describing the scene.'},
];

Future<void> savePrompts(List<Map<String, String>> prompts) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> promptList = prompts.map((prompt) => '${prompt['title']}|${prompt['prompt']}').toList();
  await prefs.setStringList('prompts', promptList);
}

Future<List<Map<String, String>>> loadPrompts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? promptList = prefs.getStringList('prompts');
  if (promptList != null) {
    return promptList.map((prompt) {
      List<String> parts = prompt.split('|');
      return {'title': parts[0], 'prompt': parts[1]};
    }).toList();
  }
  return defaultPrompts;
}

Future<void> saveSelectedPromptIndex(int selectedPromptIndex) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('selectedPromptIndex', selectedPromptIndex);
}

Future<int> loadSelectedPromptIndex() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('selectedPromptIndex') ?? 0;
}

// eof
