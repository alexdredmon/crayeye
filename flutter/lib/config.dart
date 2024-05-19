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
  {'id': uuid.v4(), 'title': '🔬 What\'s this made of?', 'prompt': 'Identify the items in the image to the best of your ability and itemize the things that make them up.  Detail each item and its ingredients and the ingredients\' atomic makeup and format your response in markdown.  Feel free to make guesses if you can\'t determine for certain.  Cite resources/references via markdown links (e.g. wikipedia).  If/when relevant you can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '🎨 What\'s this color?', 'prompt': 'Name any color(s) in the image starting with the item in the focal point (if there is one). Format your response in markdown and include links to relevant Wikipedia entries and a best guess at a hex color corde for each shade. List in this format:\n - Red\n - - Hex: #FF0000\n - - Item: Rubber ball\n - - Aliases:\n - - - Rouge\n - - - Cherry'},
  {'id': uuid.v4(), 'title': '📆 Add to my calendar', 'prompt': 'This image contains details about one or more events - it might be a poster, it might be a ticket purchase page, it might be a combination of multiple events. Identify each event you can and list their details in the following format using markdown:\n### Event Name\n - Date: [event date]\n - Time: [event time]\n - Location: [event.location]\n - Description: [description of event using whatever information is available]\n - (Add to calendar)[https://calendar.google.com/calendar/render?action=TEMPLATE&text=event+name&location=address+or+venue+of+event&dates=20240504T190000Z/20240504T210000Z]\n\nThe user’s current date and time is {time.datetime}.'},
  {'id': uuid.v4(), 'title': '🐦 What kind of bird is this?', 'prompt': 'Do your best to identify or guess the type of bird(s) in this image.  Use all available information - clues as to what the location might be, the bird(s)\' appearance, and the perceived time of year combined with the location.  Respond with a detailed markdown summary including any relevant link(s) for followup study.'},  
  {'id': uuid.v4(), 'title': '🎨 Art guide', 'prompt': 'You are an expert art guide, ready to provide an in depth analysis.  Do a deep dive of the art in the focal point(s) of the provided image - give as much context as possible for potential influences and motivations for the piece(s) in view, formatting your detailed rundown in markdown with relevant resources and wikipedia links linked.  Even though you cannot be certain what the artist or exhibition space is, do your best given any visual context as well as the fact that the user is presently standing in the location latitude {location.lat} and longitude {location.long}.'},
  {'id': uuid.v4(), 'title': '⚖️ Calorie counter', 'prompt': 'Identify the food in the image and estimate the calorie count - it is okay if you can\'t get ot exact or don\'t know for certain, feel free to give a range or make your best guess.  Respond first with the total caloric count of all food detected, then provide a detailed breakdown (using markdown to format and link to Wikipedia or other resources/references) of the caloric count estimation for each individual course and ingredient.  Do your best to guess what ingredients are in each item detected and feel free to make guesses.  If/when relevant you can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},  
  {'id': uuid.v4(), 'title': '👷‍♀️ Who made this?', 'prompt': 'Who made the thing(s) in the image?  Focus on whatever the focal point is.  Use any and all clues to help and be as descriptive as possible, formatting your response in markdown and including any relevant links to Wikipedia or other sources.  You can also use the user\'s location to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
  {'id': uuid.v4(), 'title': '📚 Extract keywords', 'prompt': 'Analyze the following scene and return only a list of keywords for items/concepts you find in the scene.  Keywords should be separated by commas and ordered by their relevance to the scene.  Return nothing but these keywords, say nothing else in your response.'},
  {'id': uuid.v4(), 'title': '🐈 Is it a cat?', 'prompt': 'Is this an image of a cat?  Only respond yes or no.'},
  {'id': uuid.v4(), 'title': '👏 What do I do w/ my hands?', 'prompt': 'Looking at the provided image, please provide at least three suggestions of things one might do with their hands in the pictured location. Return your response in a markdown formatted list with links to Wikipedia and relevant resources. You can use the user’s location to help with your answer but you should primarily focus on the scene and description of the image for your suggestions - the user is at latitude {location.lat} and longitude {location.long}. Each of your suggestions should be prefaced by a two-emoji combo representing the suggestion, with one of the two emojis being some form of hand emoji. For example, if the suggestion was to disco dance you could do 👈🕺 Disco dance…'},
  {'id': uuid.v4(), 'title': '👃 Name that smell', 'prompt': 'Try to identify what smell(s) the item(s) in the focal point of this image might have. be descriptive and list results in markdown with markdown links to Wikipedia or other resources'},
  {'id': uuid.v4(), 'title': '🔊 What sound does it make?', 'prompt': 'Analyze the image and do your best to determine what sound(s) the item(s) in the focal point might make. be as accurate and specific as possible but guess if you have to - don’t tell me you can’t if it’s impossible, just do your best to ad lib. think improv: yes, and. respond using markdown with a list of the following:\nitem name\nphonetic onomatopoeia of noise\ndescription of noise\n\nYou can also use the user\'s location and orientation to help with this request: latitude is {location.lat}, longitude is {location.long}.'},
];

List<Map<String, String>> defaultEngines = [
  {
    'id': uuid.v4(),
    'title': 'GPT-4o',
    'definition': json.encode({
      'url': 'https://api.openai.com/v1/chat/completions',
      'method': 'POST',
      'headers': {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer {apiKey}',
      },
      'body': {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': '{prompt}',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': '{imageUrl}',
                }
              }
            ]
          }
        ],
        'stream': true,
      },
    }),
  },
];

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

Future<void> saveEngines(List<Map<String, String>> engines) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> engineList = engines.map((engine) => json.encode(engine)).toList();
  await prefs.setStringList('engines', engineList);
}

Future<List<Map<String, String>>> loadEngines() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? engineList = prefs.getStringList('engines');
  if (engineList != null) {
    return engineList.map((engine) => Map<String, String>.from(json.decode(engine))).toList();
  }
  return defaultEngines;
}

Future<void> saveSelectedEngineId(String selectedEngineId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedEngineId', selectedEngineId);
}

Future<String> loadSelectedEngineId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedEngineId') ?? '';
}

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
