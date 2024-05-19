// FILENAME: camera_functions.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_compass/flutter_compass.dart';
import 'package:intl/intl.dart';
import 'config.dart';

class CameraFunctions {
  static Future<CameraDescription> getCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();
    return cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  static Future<File?> takePicture(CameraController controller, {bool keepFlashOn = false}) async {
    try {
      // Ensure that the camera is initialized
      await controller.initialize();

      // Construct the path where the image will be saved
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Set the exposure mode to auto before capturing the image
      await controller.setExposureMode(ExposureMode.auto);

      // Turn on the flash if it's supposed to be kept on
      if (keepFlashOn) {
        await controller.setFlashMode(FlashMode.torch);
      }

      // Take the picture and save it to the constructed path
      XFile picture = await controller.takePicture();

      // Return the image file
      return File(picture.path);
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  static Future<void> analyzePicture(
    CameraController controller,
    List<Map<String, String>> prompts,
    String selectedPromptUuid,
    Function(File?, String, bool) onAnalysisComplete,
    Function() onOpenAIKeyMissing,
    Function() onInvalidOpenAIKey, // Add this line
    bool keepFlashOn,
    CancelToken cancelToken,
    Map<String, String> selectedEngine,
  ) async {
    String openAIKey = await loadOpenAIKey();
    if (openAIKey.isEmpty) {
      if (DEFAULT_OPENAI_API_KEY.isEmpty) {
        onOpenAIKeyMissing();
        return;
      }
      openAIKey = DEFAULT_OPENAI_API_KEY;
    }

    // Get the user's current heading
    // double? heading = await FlutterCompass.events!.first.then((value) => value.heading);

    // Take a picture without the default shutter sound, keeping the flash on if necessary
    File? imageFile = await takePicture(controller, keepFlashOn: keepFlashOn);

    if (imageFile != null) {
      // Set the initial state with the captured image and loading state
      onAnalysisComplete(imageFile, '', true);

      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);

      // Prepare the request payload
      String prompt = prompts.firstWhere((prompt) => prompt['id'] == selectedPromptUuid)['prompt']!; // Find the prompt using UUID

      // Request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (
        prompt.contains("{location.")
        && permission != LocationPermission.denied
        && permission != LocationPermission.deniedForever
      ) {
        // Get the user's current location
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        // Replace the location tokens in the prompt with actual values
        if (prompt.contains("{location.lat}")) {
          prompt = prompt.replaceAll("{location.lat}", position.latitude.toString());
        }
        if (prompt.contains("{location.long}")) {
          prompt = prompt.replaceAll("{location.long}", position.longitude.toString());
        }
        if (prompt.contains("{location.alt}")) {
          prompt = prompt.replaceAll("{location.alt}", position.altitude.toString());
        }
      }

      if (prompt.contains("{time.")) {
        final now = DateTime.now();
        final timeZone = now.timeZoneName;

        final formatter = DateFormat('EEEE, MMMM d y \'at\' h:mma');
        final formattedDateTime = formatter.format(now);
        prompt = prompt.replaceAll("{time.datetime}", '$formattedDateTime $timeZone');
      }

      // Replace the orientation token in the prompt with actual value
      // if (prompt contains("{location.orientation}")) {
      //   String orientation;
      //   if (heading != null) {
      //     if (heading >= 315 || heading < 45) {
      //       orientation = "north";
      //     } else if (heading >= 45 && heading < 135) { 
      //       orientation = "east";
      //     } else if (heading >= 135 && heading < 225) {
      //       orientation = "south";
      //     } else {
      //       orientation = "west";
      //     }
      //   } else {
      //     orientation = "unknown";
      //   }
      //   prompt = prompt.replaceAll("{location.orientation}", orientation);
      // }

      final engineSpec = json.decode(selectedEngine['definition']!);
      print('engineSpec: $engineSpec');
      final requestUrl = engineSpec['url'] as String;
      final method = engineSpec['method'] as String;
      final headers = (engineSpec['headers'] as Map<String, dynamic>).map((key, value) => MapEntry(key.toString(), value.toString().replaceAll('{apiKey}', openAIKey)));
      final bodyMap = engineSpec['body'] as Map<String, dynamic>;
      bodyMap['messages'] = [
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
      ];
      final body = json.encode(bodyMap);

      print('Request URL: $requestUrl');
      print('Request Method: $method');
      print('Request Headers: $headers');
      // print('Request Body: $body');

      try {
        final request = http.Request(method, Uri.parse(requestUrl))
          ..headers.addAll(headers)
          ..body = body;

        final response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = '';
          await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
            if (cancelToken.isCancellationRequested) {
              response.stream.listen((_) {}).cancel(); // Cancel the stream
              break;
            }

            if (chunk.startsWith('data:') && chunk != 'data: [DONE]') {
              var data = jsonDecode(chunk.substring(5).trim()) as Map<String, dynamic>;
              onAnalysisComplete(imageFile, responseBody, true);
              if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
                String content = (data['choices'][0]['delta']['content'] ?? '') as String;
                responseBody += content;
                onAnalysisComplete(imageFile, responseBody, true);
              }
            }
          }

          if (!cancelToken.isCancellationRequested) {
            onAnalysisComplete(imageFile, responseBody, false);
          }
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          onInvalidOpenAIKey(); // Call the callback function when the API key is invalid
          onAnalysisComplete(null, 'Invalid API Key', false);
        } else {
          print('Request failed with status: ${response.statusCode}.');
          if (!cancelToken.isCancellationRequested) {
            onAnalysisComplete(null, 'Error sending image (${response.statusCode})', false);
          }
        }
      } catch (e) {
        // Update the state with the error message and loading state
        print('Error sending image: $e');
        if (!cancelToken.isCancellationRequested) {
          onAnalysisComplete(null, 'Error sending image: $e', false);
        }
      }
    } else {
      // Update the state indicating no image was captured and loading state
      print('Failed to capture image');
      if (!cancelToken.isCancellationRequested) {
        onAnalysisComplete(null, 'Failed to capture image', false);
      }
    }
  }
}

class CancelToken {
  bool isCancellationRequested = false;
}
// eof
