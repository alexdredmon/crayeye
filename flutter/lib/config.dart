// FILENAME: config.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

const String DEFAULT_OPENAI_API_KEY = String.fromEnvironment('DEFAULT_OPENAI_API_KEY', defaultValue: '');
const bool ALLOW_USER_API_KEY = true;
const bool PORTRAIT_ONLY = true;
const int MAX_MOOCH_REQUESTS = 15;
const int MOOCH_REQUEST_PERIOD = 3600;

List<Map<String, String>> defaultPrompts = [
  {'id': uuid.v4(), 'title': '🐦 What kind of bird is this? ', 'prompt': 'Do your best to identify or guess the type of bird(s) in this image.  Use all available information - clues as to what the location might be, the bird(s)\' apeparance, and the perceived time of year combined with the location.  Respond with a detailed markdown summary including any relevant link(s) for followup study.'},
  {'id': uuid.v4(), 'title': '⚖️ Calorie counter ', 'prompt': 'Identify the food in the image and estimate the calorie count - it is okay if you can\'t get ot exact or don\'t know for certain, feel free to give a range or make your best guess.  Respond first with the total caloric count of all food detected, then provide a detailed breakdown (using markdown to format and link to Wikipedia or other resources/references) of the caloric count estimation for each individual course and ingredient.  Do your best to guess what ingredients are in each item detected and feel free to make guesses.  If/when relevant you can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '🔬 What\'s this made of? ', 'prompt': 'Identify the items in the image to the best of your ability and itemize the things that make them up.  Detail each item and its ingredients and the ingredients\' atomic makeup and format your response in markdown.  Feel free to make guesses if you can\'t determine for certain.  Cite resources/references via markdown links (e.g. wikipedia).  If/when relevant you can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '👷‍♀️ Who made this? ', 'prompt': 'Who made the thing(s) in the image?  Focus on whatever the focal point is.  Use any and all clues to help and be as descriptive as possible, formatting your response in markdown and including any relevant links to Wikipedia or other sources.  You can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '📍 Where am I? ', 'prompt': 'Try to deterine where you are based on this image - do as best as you can even if it seems impossible.  Try to be specific about where you are, lean into generalization about the sights, materials, colors, etc. that you see.  You can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '📚 Extract keywords ', 'prompt': 'Analyze the following scene and return only a list of keywords for items/concepts you find in the scene.  Keywords should be separated by commas and ordered by their relevance to the scene.  Return nothing but these keywords, say nothing else in your response.'},
  {'id': uuid.v4(), 'title': '🐈 Is it a cat? ', 'prompt': 'Is this an image of a cat?  Only respond yes or no.'},
  {'id': uuid.v4(), 'title': '🤷‍♀️ What is this? ', 'prompt': 'Identify the thing(s) in the image with a focus on whatever the focal point is.  Use any and all clues to help and be as descriptive as possible, formatting your response in markdown and including any relevant links to Wikipedia or other sources.  You can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
];

// Add this class to represent a favorite item
class FavoriteItem {
  final String uuid;
  final File imageFile;
  final String response;
  final String promptTitle;
  final String prompt;

  FavoriteItem({
    required this.uuid,
    required this.imageFile,
    required this.response,
    required this.promptTitle,
    required this.prompt,
  });

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'imageFilePath': imageFile.path,
        'response': response,
        'promptTitle': promptTitle,
        'prompt': prompt,
      };

  static FavoriteItem fromJson(Map<String, dynamic> json) => FavoriteItem(
        uuid: json['uuid'],
        imageFile: File(json['imageFilePath']),
        response: json['response'],
        promptTitle: json['promptTitle'],
        prompt: json['prompt'],
      );
}

Future<void> savePrompts(List<Map<String, String>> prompts) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> promptList = prompts.map((prompt) => '${prompt['id']}|${prompt['title']}|${prompt['prompt']}').toList();
  await prefs.setStringList('prompts', promptList);
}

Future<List<Map<String, String>>> loadPrompts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? promptList = prefs.getStringList('prompts');
  if (promptList != null) {
    return promptList.map((prompt) {
      List<String> parts = prompt.split('|');
      return {'id': parts[0], 'title': parts[1], 'prompt': parts[2]};
    }).toList();
  }
  return defaultPrompts;
}

Future<void> saveSelectedPromptUuid(String selectedPromptUuid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedPromptUuid', selectedPromptUuid);
}

Future<String> loadSelectedPromptUuid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedPromptUuid') ?? '';
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

// Add these methods to save and load favorites
Future<void> saveFavorites(List<FavoriteItem> favorites) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favoriteList = favorites.map((favorite) => json.encode(favorite.toJson())).toList();
  await prefs.setStringList('favorites', favoriteList);
}

Future<List<FavoriteItem>> loadFavorites() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoriteList = prefs.getStringList('favorites');
  if (favoriteList != null) {
    return favoriteList.map((favorite) => FavoriteItem.fromJson(json.decode(favorite))).toList();
  }
  return [];
}

Future<void> saveMoochRequestCount(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('moochRequestCount', count);
}

Future<int> loadMoochRequestCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('moochRequestCount') ?? 0;
}

Future<void> saveMoochRequestTimestamp(int timestamp) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('moochRequestTimestamp', timestamp);
}

Future<int> loadMoochRequestTimestamp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('moochRequestTimestamp') ?? 0;
}
// eof
