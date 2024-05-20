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
import 'package:intl/intl.dart';
import 'config.dart';

class CameraFunctions {
  static Future<CameraDescription> getCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();
    return cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  static Future<File?> takePicture(CameraController controller, {bool keepFlashOn = false}) async {
    try {
      await controller.initialize();
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await controller.setExposureMode(ExposureMode.auto);

      if (keepFlashOn) {
        await controller.setFlashMode(FlashMode.torch);
      }

      XFile picture = await controller.takePicture();
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
    Function() onInvalidOpenAIKey,
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

    File? imageFile = await takePicture(controller, keepFlashOn: keepFlashOn);

    if (imageFile != null) {
      onAnalysisComplete(imageFile, '', true);
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);

      String prompt = prompts.firstWhere((prompt) => prompt['id'] == selectedPromptUuid)['prompt']!;
      LocationPermission permission = await Geolocator.requestPermission();
      if (
        prompt.contains("{location.")
        && permission != LocationPermission.denied
        && permission != LocationPermission.deniedForever
      ) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

      if (prompt.contains("{gif.")) {
        prompt = prompt.replaceAll("{gif.yes}", '![Yes](https://www.crayeye.com/img/app/yes.gif)');
        prompt = prompt.replaceAll("{gif.no}", '![No](https://www.crayeye.com/img/app/no.gif)');
      }

      final engineTitle = selectedEngine['title'];
      print('TITLE: $engineTitle');
      final engineSpec = json.decode(selectedEngine['definition']!);
      print('engineSpec: $engineSpec');
      final requestUrl = engineSpec['url'] as String;
      final method = engineSpec['method'] as String;
      String apiKey = (selectedEngine['origin'] == 'system' ? openAIKey : '');
      final headers = (engineSpec['headers'] as Map<String, dynamic>).map((key, value) => MapEntry(key.toString(), value.toString().replaceAll('{apiKey}', apiKey)));
      final bodyTemplate = engineSpec['body'] as Map<String, dynamic>;
      final body = json.encode(_interpolateBody(bodyTemplate, prompt, base64Image));
      final responseShape = engineSpec['responseShape'] as List<dynamic>;

      print('Request URL: $requestUrl');
      print('Request Method: $method');
      print('Request Headers: $headers');
      print('Request Body: $body');

      try {
        final request = http.Request(method, Uri.parse(requestUrl))
          ..headers.addAll(headers)
          ..body = body;

        final response = await request.send();

        if (response.statusCode == 200) {
          String responseBody = '';
          await for (var chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
            if (cancelToken.isCancellationRequested) {
              print("cancel requested");
              response.stream.listen((_) {}).cancel();
              break;
            }
            if (chunk.startsWith('data:') && chunk != 'data: [DONE]') {
              var data = jsonDecode(chunk.substring(5).trim()) as Map<String, dynamic>;
              String parsed = _parseResponse(data, responseShape);
              responseBody += parsed;
              onAnalysisComplete(imageFile, responseBody, true);
            } else {
              try {
                Map<String, dynamic> decodedChunk = jsonDecode(chunk);
                String parsed = _parseResponse(decodedChunk, responseShape);
                responseBody += parsed;
                onAnalysisComplete(imageFile, responseBody, true);
              } catch (e) {
                print("There was an error: $e");
              }
            }
          }

          if (!cancelToken.isCancellationRequested) {
            onAnalysisComplete(imageFile, responseBody, false);
          }
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          onInvalidOpenAIKey();
          onAnalysisComplete(null, 'Invalid API Key', false);
        } else {
          print('Request failed with status: ${response.statusCode}.');
          try {
            String responseBody = await response.stream.bytesToString();
            print('Response body: $responseBody');
            if (!cancelToken.isCancellationRequested) {
              onAnalysisComplete(null, 'Error sending image (${response.statusCode}): $responseBody', false);
            }
          } catch (e) {
            print('Error reading response body: $e');
            if (!cancelToken.isCancellationRequested) {
              onAnalysisComplete(null, 'Error sending image (${response.statusCode})', false);
            }
          }
        }
      } catch (e) {
        print('Error sending image: $e');
        if (!cancelToken.isCancellationRequested) {
          onAnalysisComplete(null, 'Error sending image: $e', false);
        }
      }
    } else {
      print('Failed to capture image');
      if (!cancelToken.isCancellationRequested) {
        onAnalysisComplete(null, 'Failed to capture image', false);
      }
    }
  }

  static Map<String, dynamic> _interpolateBody(Map<String, dynamic> bodyTemplate, String prompt, String base64Image) {
    var body = json.decode(json.encode(bodyTemplate)); // deep copy
    String bodyString = json.encode(body);

    bodyString = bodyString.replaceAll("{prompt}", prompt);
    bodyString = bodyString.replaceAll("{imageUrl}", "data:image/png;base64,$base64Image");
    bodyString = bodyString.replaceAll("{imageBase64}", "$base64Image");

    return json.decode(bodyString);
  }

  static String _parseResponse(Map<String, dynamic> data, List<dynamic> responseShape) {
    dynamic current = data;
    for (var path in responseShape) {
      if (current is List) {
        current = current[int.parse(path.toString())];
      } else if (current is Map<String, dynamic>) {
        current = current[path];
      } else {
        current = jsonDecode(current);
      }
    }
    if (current == null) {
      current = "";
    }
    return current.toString();
  }
}

class CancelToken {
  bool isCancellationRequested = false;
}
// eof
