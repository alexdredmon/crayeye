import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
      Position? position;

      if (
        (prompt.contains("{location.") || prompt.contains("{weather.")) // Check for weather placeholders as well
        && permission != LocationPermission.denied
        && permission != LocationPermission.deniedForever
      ) {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (prompt.contains("{location.lat}")) {
          prompt = prompt.replaceAll("{location.lat}", position.latitude.toString());
        }
        if (prompt.contains("{location.long}")) {
          prompt = prompt.replaceAll("{location.long}", position.longitude.toString());
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

      if (prompt.contains("{weather.")) {
        if (position != null) {
          Map<String, String> weatherData = await _getWeatherData(position.latitude, position.longitude);
          if (prompt.contains("{weather.temp}")) {
            prompt = prompt.replaceAll("{weather.temp}", weatherData["temperature"] ?? 'N/A');
          }
          if (prompt.contains("{weather.forecast}")) {
            prompt = prompt.replaceAll("{weather.forecast}", weatherData["detailedForecast"] ?? 'N/A');
          }
        } else {
          prompt = prompt
            .replaceAll("{weather.temp}", 'N/A')
            .replaceAll("{weather.forecast}", 'N/A');
        }
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
            } else if(chunk != '') {
              try {
                Map<String, dynamic> decodedChunk = jsonDecode(chunk);
                String parsed = _parseResponse(decodedChunk, responseShape);
                responseBody += parsed;
                onAnalysisComplete(imageFile, responseBody, true);
              } catch (e) {
                print("There was an error decoding '$chunk': $e");
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

    // Properly escape newlines in the prompt and JSON string
    prompt = prompt.replaceAll("\n", "\\n");
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

  static Future<Map<String, String>> _getWeatherData(double latitude, double longitude) async {
    Map<String, String> weatherData = {'temperature': 'N/A', 'detailedForecast': 'N/A'};

    try {
      // Round latitude and longitude to four decimal places
      latitude = double.parse(latitude.toStringAsFixed(4));
      longitude = double.parse(longitude.toStringAsFixed(4));

      // Fetch the forecast URL
      final pointUrl = 'https://api.weather.gov/points/$latitude,$longitude';
      final pointResponse = await http.get(Uri.parse(pointUrl), headers: {
        'User-Agent': '(CrayEye, email@alexredmon.com)',
      });

      if (pointResponse.statusCode == 200) {
        final pointData = json.decode(pointResponse.body);
        final forecastUrl = pointData['properties']['forecast'];

        // Fetch the temperature and detailed forecast from the forecast URL
        final forecastResponse = await http.get(Uri.parse(forecastUrl), headers: {
          'User-Agent': '(CrayEye, email@alexredmon.com)',
        });

        if (forecastResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final periods = forecastData['properties']['periods'];
          final temperature = periods[0]['temperature'];
          final detailedForecast = periods[0]['detailedForecast'];

          weatherData['temperature'] = '$temperature degrees Fahrenheit';
          weatherData['detailedForecast'] = detailedForecast;
        }
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
    return weatherData;
  }
}

class CancelToken {
  bool isCancellationRequested = false;
}
// eof