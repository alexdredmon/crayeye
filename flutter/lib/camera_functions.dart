// FILENAME: camera_functions.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'config.dart';

class CameraFunctions {
  static Future<CameraDescription> getCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();
    return cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  static Future<File?> takePicture(CameraController controller) async {
    try {
      // Ensure that the camera is initialized
      await controller.initialize();

      // Construct the path where the image will be saved
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Take the picture and save it to the constructed path
      XFile picture = await controller.takePicture();

      // Return the image file
      return File(picture.path);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<void> analyzePicture(
    CameraController controller,
    List<Map<String, String>> prompts,
    int selectedPromptIndex,
    Function(File?, String, bool) onAnalysisComplete,
    Function() onOpenAIKeyMissing,
  ) async {
    String openAIKey = await loadOpenAIKey();
    if (openAIKey.isEmpty) {
      openAIKey = DEFAULT_OPENAI_API_KEY;
      // onOpenAIKeyMissing();
      // return;
    }

    // Take a picture without the default shutter sound
    File? imageFile = await takePicture(controller);

    if (imageFile != null) {
      // Set the initial state with the captured image and loading state
      onAnalysisComplete(imageFile, '', true);

      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);

      // Prepare the request payload
      String prompt = prompts[selectedPromptIndex]['prompt']!;
      Map<String, dynamic> body = {
        'model': 'gpt-4-vision-preview',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': prompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,$base64Image',
                }
              }
            ]
          }
        ],
      };

      try {
        // Send the image to OpenAI for analysis
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIKey',
          },
          body: jsonEncode(body),
        );

        // Parse the response
        final responseData = jsonDecode(response.body);
        String responseBody = response.body;
        if (responseData.containsKey('error')) {
          responseBody = responseData['error']['message'];
        }
        if (responseData.containsKey('choices')) {
          responseBody = responseData['choices'][0]['message']['content'];
        }

        // Update the state with the analysis result and loading state
        onAnalysisComplete(imageFile, responseBody, false);
      } catch (e) {
        // Update the state with the error message and loading state
        onAnalysisComplete(null, 'Error sending image: $e', false);
      }
    } else {
      // Update the state indicating no image was captured and loading state
      onAnalysisComplete(null, 'Failed to capture image', false);
    }
  }
}
// eof
