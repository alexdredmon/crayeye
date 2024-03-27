// home_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'config.dart';
import 'camera_preview.dart';
import 'prompts_drawer.dart';

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
  List<Map<String, String>> _prompts = defaultPrompts;
  int _selectedPromptIndex = 0;

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
      String body = jsonEncode({
        'base64': imgBase64,
        'prompt': _prompts[_selectedPromptIndex]['prompt']!
      });

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

  void _showPromptsDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return PromptsDrawer(
          prompts: _prompts,
          onEditPrompt: _showEditPromptDialog,
          onDeletePrompt: (index) {
            setState(() {
              _prompts.removeAt(index);
              if (_selectedPromptIndex >= _prompts.length) {
                _selectedPromptIndex = _prompts.length - 1;
              }
            });
            Navigator.pop(context);
          },
          onAddPrompt: _showAddPromptDialog,
        );
      },
    );
  }

  void _showAddPromptDialog() {
    String newTitle = '';
    String newPrompt = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Prompt',
            style: TextStyle(color: Colors.white)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  newTitle = value;
                },
              ),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prompt',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  newPrompt = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _prompts.add({'title': newTitle, 'prompt': newPrompt});
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

  void _showEditPromptDialog(int index) {
    String updatedTitle = _prompts[index]['title']!;
    String updatedPrompt = _prompts[index]['prompt']!;
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Text(
            'Edit Prompt',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(text: updatedTitle),
                onChanged: (value) {
                  updatedTitle = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Prompt',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(text: updatedPrompt),
                onChanged: (value) {
                  updatedPrompt = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _prompts[index]['title'] = updatedTitle;
                  _prompts[index]['prompt'] = updatedPrompt;
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

  void _startNewScan() {
    setState(() {
      _imageFile = null;
      _responseBody = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: Center( // Center the title widget
          child: Image(
            image: AssetImage('images/crayeye.png'),
            height: 30.0, // Set the height to 75px
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.list),
        //     onPressed: _showPromptsDrawer,
        //   ),
        // ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageFile == null && _initializeControllerFuture != null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreviewWidget(controller: _controller!);
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            if (_imageFile == null && !_isAnalyzing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: _selectedPromptIndex,
                    items: List.generate(
                      _prompts.length,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          _prompts[index]['title']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedPromptIndex = value!;
                      });
                    },
                    dropdownColor: Colors.blueGrey.shade800,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showPromptsDrawer,
                    color: Colors.white,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            _isAnalyzing
                ? const CircularProgressIndicator() // Show loading spinner when analyzing
                : ElevatedButton.icon(
                    onPressed: _responseBody.isNotEmpty ? _startNewScan : _analyzePicture,
                    icon: Icon(_responseBody.isNotEmpty ? Icons.refresh : Icons.camera_alt),
                    label: Text(_responseBody.isNotEmpty ? "New Scan" : "Analyze"),
                  ),
            const SizedBox(height: 16), // Add some spacing
            if (!_isAnalyzing && _responseBody.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_imageFile != null)
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Image.file(_imageFile!),
                          ),
                        ),
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
                            Text(
                              _responseBody,
                              style: TextStyle(
                                color: Colors.blueGrey.shade100,
                              ),
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
                              _prompts[_selectedPromptIndex]['prompt']!,
                              style: TextStyle(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _imageFile == null && _initializeControllerFuture != null
          ? FloatingActionButton(
              onPressed: _switchCamera,
              child: const Icon(Icons.cameraswitch),
            )
          : null,
    );
  }
}

// eof
