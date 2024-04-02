// FILENAME: home_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'camera_preview.dart';
import 'prompts_drawer.dart';
import 'camera_functions.dart';
import 'response_view.dart';
import 'key_dialog.dart';
import 'help_drawer.dart';
import 'prompt_dialogs.dart';
import 'package:provider/provider.dart';
import 'prompt_notifier.dart';
import 'audio_manager.dart';
import 'floating_action_buttons.dart';
import 'home_app_bar.dart';
import 'cancelable_operation.dart';
import 'prompt_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _capturedImage;
  String _responseBody = '';
  CameraLensDirection _cameraDirection = CameraLensDirection.back;
  bool _isAnalyzing = false;
  List<Map<String, String>> _prompts = [];
  int _selectedPromptIndex = 0;
  bool _isSwitchingCamera = false;
  bool _isFlashOn = false;
  late AudioManager _audioManager;
  CancelableOperation<void>? _analyzeOperation;

  @override
  void initState() {
    super.initState();
    initCamera();
    _audioManager = AudioManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPrompts();
  }

  void _loadPrompts() async {
    List<Map<String, String>> loadedPrompts = await loadPrompts();
    int loadedSelectedPromptIndex = await loadSelectedPromptIndex();
    setState(() {
      _prompts = loadedPrompts;
      _selectedPromptIndex = loadedSelectedPromptIndex;
    });

    var promptNotifier = Provider.of<PromptNotifier>(context, listen: false);
    if (promptNotifier.prompt != null) {
      _handleInitialPrompt(promptNotifier.prompt!, promptNotifier.title!);
    }
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
    _audioManager.dispose();
    super.dispose();
  }

  void _startNewScan() {
    setState(() {
      _capturedImage = null;
      _responseBody = '';
    });
    _audioManager.stopAudio();
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
    if (_audioManager.isAudioEnabledNotifier.value) {
      _audioManager.disableAudio();
      _audioManager.stopAudio();
    } else {
      _audioManager.enableAudio();
      if (_isAnalyzing) {
        _audioManager.playRandomAudio();
      }
    }
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

  void _handleInitialPrompt(String prompt, String title) {
    showAddPromptDialog(
      context,
      (title, prompt) {
        setState(() {
          _prompts.add({'title': title, 'prompt': prompt});
          _selectedPromptIndex = _prompts.length - 1;
        });
        savePrompts(_prompts);
        saveSelectedPromptIndex(_selectedPromptIndex);
      },
      initialPrompt: prompt,
      initialTitle: title,
    );
  }

  void _analyzeImage() async {
    _audioManager.playRandomAudio();
    _analyzeOperation = CancelableOperation.fromFuture(
      CameraFunctions.analyzePicture(
        _controller!,
        _prompts,
        _selectedPromptIndex,
        (capturedImage, responseBody, isAnalyzing) {
          setState(() {
            _capturedImage = capturedImage;
            _responseBody = responseBody;
            _isAnalyzing = isAnalyzing;
            if (!isAnalyzing) {
              _audioManager.stopAudio();
              _analyzeOperation = null;
            }
            if (isAnalyzing && _isFlashOn) {
              _toggleFlash();
            }
          });
        },
        _onOpenAIKeyMissing,
        _isFlashOn,
      ),
    );
  }

  void _cancelAnalysis() {
    if (_analyzeOperation != null && !_analyzeOperation!.isCompleted) {
      _analyzeOperation!.cancel();
      setState(() {
        _isAnalyzing = false;
        _capturedImage = null;
        _responseBody = '';
        _analyzeOperation = null;
      });
      _audioManager.stopAudio();
    }
  }

  void _switchCamera() async {
    setState(() {
      _isSwitchingCamera = true;
      _cameraDirection = (_cameraDirection == CameraLensDirection.back)
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      if (_cameraDirection == CameraLensDirection.front && _isFlashOn) {
        _toggleFlash();
      }
    });
    await _controller?.dispose();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    String? prompt = Provider.of<PromptNotifier>(context).prompt;
    String? title = Provider.of<PromptNotifier>(context).title;
    if (prompt != null && title != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (prompt.isNotEmpty) {
          _handleInitialPrompt(prompt, title);
          Provider.of<PromptNotifier>(context, listen: false).setPromptAndTitle(null, null);
        }
      });
    }

    final isValidIndex = _selectedPromptIndex >= 0 && _selectedPromptIndex < _prompts.length;
    final currentPromptTitle = isValidIndex ? _prompts[_selectedPromptIndex]['title'] : 'Select a Prompt';

    return Scaffold(
      appBar: HomeAppBar(
        audioManager: _audioManager,
        toggleAudio: _toggleAudio,
      ),
      body: Stack(
        children: [
          Column(
            children: [
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
                      return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                    }
                  },
                ),
              const SizedBox(height: 16),
              if (!_isAnalyzing && _responseBody.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: ResponseView(
                      imageFile: _capturedImage,
                      responseBody: _responseBody,
                      prompt: _prompts[_selectedPromptIndex]['prompt']!,
                    ),
                  ),
                ),
            ],
          ),
          if (!_isAnalyzing && _responseBody.isEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: PromptButton(
                    currentPromptTitle: currentPromptTitle!,
                    onPressed: () {
                      showPromptsDrawer(
                        context: context,
                        prompts: _prompts,
                        selectedPromptIndex: _selectedPromptIndex,
                        onPromptsUpdated: _updatePrompts,
                        onAnalyzePressed: _analyzeImage,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButtons(
        isAnalyzing: _isAnalyzing,
        responseBody: _responseBody,
        isFlashOn: _isFlashOn,
        cameraDirection: _cameraDirection,
        toggleFlash: _toggleFlash,
        switchCamera: _switchCamera,
        cancelAnalysis: _cancelAnalysis,
        startNewScan: _startNewScan,
        analyzeImage: _analyzeImage,
      ),
    );
  }
}
// eof
