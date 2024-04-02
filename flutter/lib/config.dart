// config.dart
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

const String DEFAULT_OPENAI_API_KEY = String.fromEnvironment('DEFAULT_OPENAI_API_KEY', defaultValue: '');
const bool PORTRAIT_ONLY = true;

List<Map<String, String>> defaultPrompts = [
  {'title': '📸 Describe image', 'prompt': 'Describe this image'},
  {'title': '📚 Keyword extraction ', 'prompt': 'Analyze the following scene and return only a list of keywords for items/concepts you find in the scene.  Keywords should be separated by commas and ordered by their relevance to the scene.  Return nothing but these keywords, say nothing else in your response.'},
  {'title': '🐈 Is it a cat? ', 'prompt': 'Is this an image of a cat?  Only respond yes or no.'},
  {'title': '🐦 What kind of bird is this? ', 'prompt': 'Do your best to identify or guess the type of bird(s) in this image.  Use all available information - clues as to what the location might be, the bird(s)\' apeparance, and the perceived time of year combined with the location.  Respond with a detailed markdown summary including any relevant link(s) for followup study.'},
  {'title': '📍 Where am I? ', 'prompt': 'Try to deterine where you are based on this image - do as best as you can even if it seems impossible.  Try to be specific about where you are, lean into generalization about the sights, materials, colors, etc. that you see.  You can also use the user\'s lat/long to help with this request: latitude is {location.lat} and longitude is {location.long}'},
  {'title': '🤷‍♀️ What is this? ', 'prompt': 'Identify the thing(s) in the image with a focus on whatever the focal point is.  Use any and all clues to help and be as descriptive as possible, formatting your response in markdown and including any relevant links to Wikipedia or other sources.  You can also use the user\'s lat/long to help with this request: latitude is {location.lat} and longitude is {location.long}'},
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

Future<void> saveOpenAIKey(String openAIKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('openAIKey', openAIKey);
}

Future<String> loadOpenAIKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String openAIKey = prefs.getString('openAIKey') ?? '';
  
  if (openAIKey.isEmpty) {
    openAIKey = DEFAULT_OPENAI_API_KEY;
  }
  
  return openAIKey;
}

// eof
