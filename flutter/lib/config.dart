const String baseUrl = 'https://example';
List<Map<String, String>> defaultPrompts = [
  {'title': 'Describe image', 'prompt': 'Describe this image'},
  {'title': 'Keyword extraction ', 'prompt': 'Analyze the following scene and return only a list of keywords for items/concepts you find in the scene.  Keywords should be separated by commas and ordered by their relevance to the scene.  Return nothing but these keywords, say nothing else in your response.'},
  {'title': 'Bizarro world', 'prompt': 'Let\' play a fun game:  Craft a creative narrative describing the origin or details of the scene before you but do not base it in reality - pretend you are in a "bizarro world" where everything is the opposite of what it actually is while describing the scene.'},
];