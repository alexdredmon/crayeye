import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitten Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          background: Colors.blueGrey.shade800,
          onBackground: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kitten Scan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<CameraDescription>? cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _imageFile;
  String _responseBody = '';
  int _cameraIndex = 0; // Track the current camera index
  bool _isAnalyzing = false; // Track if the analysis is in progress
  String _prompt = "Please describe this image"; // Default prompt

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![_cameraIndex], // Use the current camera index
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller!.initialize().then((_) {
        setState(() {}); // Rebuild the widget after initialization
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _analyzePicture() async {
    setState(() {
      _isAnalyzing = true; // Set the analyzing flag to true
      _responseBody = ''; // Clear the previous response body
    });

    await _takePicture();

    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      String imgBase64 = base64Encode(bytes);

      Uri url = Uri.parse('$baseUrl/image');

      Map<String, String> headers = {"Content-Type": "application/json"};
      String body = jsonEncode({'base64': imgBase64, 'prompt': _prompt});

      try {
        final response = await http.post(url, headers: headers, body: body);
        final responseData = json.decode(response.body);
        if (responseData.containsKey('response')) {
          setState(() {
            _responseBody = responseData['response'];
          });
        } else {
          setState(() {
            _responseBody = 'Response does not contain the expected "response" attribute.';
          });
        }
      } catch (e) {
        setState(() {
          _responseBody = 'Error sending image: $e';
        });
      }
    }

    setState(() {
      _isAnalyzing = false; // Set the analyzing flag to false
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      final XFile picture = await _controller!.takePicture();

      setState(() {
        _imageFile = File(picture.path);
      });
    } catch (e) {
      print(e);
    }
  }

  void _switchCamera() {
    // Dispose the current controller
    _controller?.dispose();

    // Get the next camera index
    _cameraIndex = (_cameraIndex + 1) % cameras!.length;

    // Initialize the new controller
    _initCamera();
  }

  void _showPromptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPrompt = _prompt;
        return AlertDialog(
          title: const Text('Change Prompt'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Enter a new prompt',
            ),
            onChanged: (value) {
              newPrompt = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _prompt = newPrompt;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: const Text('🐈 Kitten Scan', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showPromptDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_initializeControllerFuture != null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: CameraPreview(_controller!),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            _isAnalyzing
                ? const CircularProgressIndicator() // Show loading spinner when analyzing
                : ElevatedButton.icon(
                    onPressed: _analyzePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Analyze"),
                  ),
            const SizedBox(height: 16), // Add some spacing
            if (!_isAnalyzing && _responseBody.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16.0), // Add margin around the container
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Complete:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Add some spacing
                    SizedBox(
                      height: 200, // Set a fixed height for the scrollable area
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _responseBody,
                              style: TextStyle(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            const SizedBox(height: 16), // Add some spacing
                            if (_imageFile != null)
                              Image.file(
                                _imageFile!,
                                height: 200, // Set a fixed height for the image
                              ),
                            const SizedBox(height: 16), // Add some spacing
                            const Text(
                              'Prompt:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8), // Add some spacing
                            Text(
                              _prompt,
                              style: TextStyle(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),
    );
  }
}
