// FILENAME: home_page.dart
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'config.dart';
import 'camera_preview.dart';
import 'prompts_drawer.dart';
import 'camera_functions.dart';
import 'response_view.dart';
import 'key_dialog.dart';
import 'help_drawer.dart'; // Import the new file for help drawer

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.initialPrompt});

  final String title;
  final String? initialPrompt;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _capturedImage;
  String _responseBody = '';
  CameraLensDirection _cameraDirection = CameraLensDirection.back;
  bool _isAnalyzing = false; // Track if the analysis is in progress
  List<Map<String, String>> _prompts = [];
  int _selectedPromptIndex = 0;
  bool _isSwitchingCamera = false; // Track if the camera is being switched
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _audioFiles = ['loading1.wav', 'loading2.wav', 'loading3.wav', 'loading4.wav'];
  bool _isFlashOn = false; // Track if the flash/light is on
  bool _isAudioEnabled = true; // Track if audio is enabled

  @override
  void initState() {
    super.initState();
    _loadPrompts();
    initCamera();
    _initAudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPrompt != null) {
        _handleInitialPrompt(widget.initialPrompt!);
      }
    });
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(1.0); // Set volume to the maximum (1.0)
  }

  Future<void> _playRandomAudio() async {
    if (_isAudioEnabled) {
      final randomIndex = Random().nextInt(_audioFiles.length);
      final audioFile = _audioFiles[randomIndex];
      await _audioPlayer.play(AssetSource(audioFile));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
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
    final camera = await CameraFunctions.getCamera(_cameraDirection);
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSwitchingCamera = false;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startNewScan() {
    setState(() {
      _capturedImage = null;
      _responseBody = '';
    });
    _stopAudio();
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _toggleAudio() {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
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

  void _onOpenAIKeyMissing() {
    showKeyDialog(context);
  }

  void _handleInitialPrompt(String prompt) async {
    await showPromptsDrawer(
      context: context,
      prompts: _prompts,
      selectedPromptIndex: _selectedPromptIndex,
      onPromptsUpdated: _updatePrompts,
      initialPrompt: prompt,
      onAnalyzePressed: _analyzeImage,
    );
  }

  void _analyzeImage() async {
    await _playRandomAudio();
    CameraFunctions.analyzePicture(
      _controller!,
      _prompts,
      _selectedPromptIndex,
      (capturedImage, responseBody, isAnalyzing) {
        if (_isFlashOn) {
          _toggleFlash();
        }
        setState(() {
          _capturedImage = capturedImage;
          _responseBody = responseBody;
          _isAnalyzing = isAnalyzing;
          if (!isAnalyzing) {
            _stopAudio();
          }
        });
      },
      _onOpenAIKeyMissing,
    );
  }

  void _switchCamera() async {
    setState(() {
      _isSwitchingCamera = true;
      _cameraDirection = (_cameraDirection == CameraLensDirection.back)
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      // When switching to the front camera, turn off the flash if it is on.
      if (_cameraDirection == CameraLensDirection.front && _isFlashOn) {
        _toggleFlash();
      }
    });
    await _controller?.dispose();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: Icon(
            _isAudioEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
          ),
          onPressed: _toggleAudio,
        ),
        title: Center( // Center the title widget
          child: Image(
            image: AssetImage('images/crayeye.png'),
            height: 30.0, // Set the height to 75px
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help, color: Colors.white),
            onPressed: () {
              showHelpDrawer(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_initializeControllerFuture != null && _responseBody.isEmpty && !_isSwitchingCamera)
                  FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreviewWidget(
                          controller: _controller!,
                          capturedImage: _isAnalyzing ? _capturedImage : null,
                        );
                      } else {
                        return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)); // White loading spinner
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (!_isAnalyzing && _responseBody.isNotEmpty)
                  ResponseView(
                    imageFile: _capturedImage,
                    responseBody: _responseBody,
                    prompt: _prompts[_selectedPromptIndex]['prompt']!,
                  ),
              ],
            ),
          ),
          if (!_isAnalyzing && _responseBody.isEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showPromptsDrawer(
                      context: context,
                      prompts: _prompts,
                      selectedPromptIndex: _selectedPromptIndex,
                      onPromptsUpdated: _updatePrompts,
                      onAnalyzePressed: _analyzeImage,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _prompts[_selectedPromptIndex]['title']!,
                        style: TextStyle(
                          // color: Color(0xFF4EFFB6),
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Show the flash toggle button only if the back camera is selected
          if (!_isAnalyzing && _responseBody.isEmpty && _cameraDirection == CameraLensDirection.back)
            FloatingActionButton(
              onPressed: _toggleFlash,
              child: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on),
            ),
          if (!_isAnalyzing && _responseBody.isEmpty && _cameraDirection == CameraLensDirection.back) const SizedBox(height: 16), // Add some spacing
          if (!_isAnalyzing && _responseBody.isEmpty)
            FloatingActionButton(
              onPressed: _switchCamera,
              child: const Icon(Icons.cameraswitch),
            ),
          if (!_isAnalyzing && _responseBody.isEmpty) const SizedBox(height: 16), // Add some spacing
          _isAnalyzing
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : FloatingActionButton(
                  backgroundColor: Colors.deepPurple.shade700,
                  onPressed: _responseBody.isNotEmpty
                      ? _startNewScan
                      : _analyzeImage,
                  child: Icon(_responseBody.isNotEmpty
                      ? Icons.arrow_back
                      : Icons.visibility,
                      color: Colors.white),
                ),
          if (!_isAnalyzing && _responseBody.isEmpty) const SizedBox(height: 40), // Add some spacing
        ],
      ),
    );
  }
}
// eof
