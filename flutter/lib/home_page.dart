// home_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'camera_preview.dart';
import 'prompts_drawer.dart';
import 'camera_functions.dart';
import 'response_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CameraDescription>? cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _capturedImage;
  String _responseBody = '';
  int _cameraIndex = 0; // Track the current camera index
  bool _isAnalyzing = false; // Track if the analysis is in progress
  List<Map<String, String>> _prompts = [];
  int _selectedPromptIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPrompts();
    initCamera();
  }

  void _loadPrompts() async {
    List<Map<String, String>> loadedPrompts = await loadPrompts();
    int loadedSelectedPromptIndex = await loadSelectedPromptIndex();
    setState(() {
      _prompts = loadedPrompts;
      _selectedPromptIndex = loadedSelectedPromptIndex;
    });
  }

  void initCamera() async {
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

  void _startNewScan() {
    setState(() {
      _capturedImage = null;
      _responseBody = '';
    });
  }

  void _updatePrompts(List<Map<String, String>> updatedPrompts, int updatedSelectedPromptIndex) {
    setState(() {
      _prompts = updatedPrompts;
      _selectedPromptIndex = updatedSelectedPromptIndex;
    });
    savePrompts(_prompts);
    saveSelectedPromptIndex(_selectedPromptIndex);
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_initializeControllerFuture != null && _responseBody.isEmpty)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreviewWidget(
                      controller: _controller!,
                      capturedImage: _isAnalyzing ? _capturedImage : null,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            if (!_isAnalyzing && _responseBody.isEmpty)
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
                      saveSelectedPromptIndex(_selectedPromptIndex);
                    },
                    dropdownColor: Colors.blueGrey.shade800,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      showPromptsDrawer(
                        context: context,
                        prompts: _prompts,
                        onPromptsUpdated: _updatePrompts,
                      );
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            _isAnalyzing
                ? const CircularProgressIndicator() // Show loading spinner when analyzing
                : ElevatedButton.icon(
                    onPressed: _responseBody.isNotEmpty
                        ? _startNewScan
                        : () => analyzePicture(
                              _controller!,
                              _prompts,
                              _selectedPromptIndex,
                              (capturedImage, responseBody, isAnalyzing) {
                                setState(() {
                                  _capturedImage = capturedImage;
                                  _responseBody = responseBody;
                                  _isAnalyzing = isAnalyzing;
                                });
                              },
                            ),
                    icon: Icon(_responseBody.isNotEmpty ? Icons.refresh : Icons.camera_alt),
                    label: Text(_responseBody.isNotEmpty ? "New Scan" : "Analyze"),
                  ),
            const SizedBox(height: 16), // Add some spacing
            if (!_isAnalyzing && _responseBody.isNotEmpty)
              ResponseView(
                imageFile: _capturedImage,
                responseBody: _responseBody,
                prompt: _prompts[_selectedPromptIndex]['prompt']!,
              ),
          ],
        ),
      ),
      floatingActionButton: _capturedImage == null && _initializeControllerFuture != null && _responseBody.isEmpty
          ? FloatingActionButton(
              onPressed: () => switchCamera(_controller!, cameras!, _cameraIndex, (newController, newCameraIndex) {
                setState(() {
                  _controller = newController;
                  _cameraIndex = newCameraIndex;
                  _initializeControllerFuture = _controller!.initialize();
                });
              }),
              child: const Icon(Icons.cameraswitch),
            )
          : null,
    );
  }
}
// eof
