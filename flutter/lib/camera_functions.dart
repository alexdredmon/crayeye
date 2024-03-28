// camera_functions.dart

import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'config.dart';

Future<void> switchCamera(
  CameraController controller,
  List<CameraDescription> cameras,
  int currentCameraIndex,
  Function(CameraController, int) onCameraSwitch,
) async {
  // Dispose the current controller
  controller.dispose();

  // Get the next camera index
  int newCameraIndex = (currentCameraIndex + 1) % cameras.length;

  // Create a new controller with the new camera index
  CameraController newController = CameraController(
    cameras[newCameraIndex],
    ResolutionPreset.medium,
  );

  // Initialize the new controller
  await newController.initialize();

  // Invoke the callback with the new controller and camera index
  onCameraSwitch(newController, newCameraIndex);
}

Future<File?> takePicture(CameraController controller) async {
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

Future<void> analyzePicture(
  CameraController controller,
  List<Map<String, String>> prompts,
  int selectedPromptIndex,
  Function(File?, String, bool) onAnalysisComplete,
) async {
  // Set the initial state
  onAnalysisComplete(null, '', true);

  // Take a picture
  File? imageFile = await takePicture(controller);

  if (imageFile != null) {
    // Read the image file as bytes
    final bytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(bytes);

    // Prepare the request payload
    String prompt = prompts[selectedPromptIndex]['prompt']!;
    Map<String, String> body = {
      'base64': base64Image,
      'prompt': prompt,
    };

    try {
      // Send the image to the server for analysis
      final response = await http.post(
        Uri.parse('$baseUrl/image'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // Parse the response
      final responseData = json.decode(response.body);
      String responseBody = responseData['response'] ?? 'No response received';

      // Update the state with the analysis result
      onAnalysisComplete(imageFile, responseBody, false);
    } catch (e) {
      // Update the state with the error message
      onAnalysisComplete(null, 'Error sending image: $e', false);
    }
  } else {
    // Update the state indicating no image was captured
    onAnalysisComplete(null, 'Failed to capture image', false);
  }
}

// eof
