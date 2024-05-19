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
import 'favorites_drawer.dart';

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
  String _selectedPromptUuid = '';
  bool _isSwitchingCamera = false;
  bool _isFlashOn = false;
  late AudioManager _audioManager;
  CancelableOperation<void>? _analyzeOperation;
  CancelToken _cancelToken = CancelToken();
  List<FavoriteItem> _favorites = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _moochRequestCount = 0;
  int _moochRequestTimestamp = 0;
  List<Map<String, String>> _engines = [];
  String _selectedEngineId = '';

  @override
  void initState() {
    super.initState();
    initCamera();
    _audioManager = AudioManager(
      onAudioEnabled: () {
        if (_isAnalyzing) {
          _audioManager.playRandomAudio();
        }
      },
    );
    _loadFavorites();
    _loadMoochRequestCount();
    _loadMoochRequestTimestamp();
    _loadEngines();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPrompts();
  }

  void resetPrompts(List<Map<String, String>> defaultPromptsList) {
    setState(() {
      _prompts = defaultPromptsList;
      _selectedPromptUuid = defaultPromptsList.first['id']!;
    });
  }

  void _loadPrompts() async {
    List<Map<String, String>> loadedPrompts = await loadPrompts();
    String loadedSelectedPromptUuid = await loadSelectedPromptUuid();
    setState(() {
      _prompts = loadedPrompts;
      _selectedPromptUuid = loadedSelectedPromptUuid;
    });

    var promptNotifier = Provider.of<PromptNotifier>(context, listen: false);
    if (promptNotifier.prompt != null) {
      _handleInitialPrompt(promptNotifier.prompt!, promptNotifier.title!);
    }
  }

  void _loadFavorites() async {
    List<FavoriteItem> loadedFavorites = await loadFavorites();
    setState(() {
      _favorites = loadedFavorites;
    });
  }

  void _loadMoochRequestCount() async {
    int count = await loadMoochRequestCount();
    setState(() {
      _moochRequestCount = count;
    });
  }

  void _loadMoochRequestTimestamp() async {
    int timestamp = await loadMoochRequestTimestamp();
    setState(() {
      _moochRequestTimestamp = timestamp;
    });
  }

  void _updateMoochRequestCount() async {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (currentTimestamp - _moochRequestTimestamp >= MOOCH_REQUEST_PERIOD) {
      await saveMoochRequestCount(1);
      await saveMoochRequestTimestamp(currentTimestamp);
      setState(() {
        _moochRequestCount = 1;
        _moochRequestTimestamp = currentTimestamp;
      });
    } else {
      await saveMoochRequestCount(_moochRequestCount + 1);
      setState(() {
        _moochRequestCount++;
      });
    }
  }

  Future<bool> _canMakeRequest() async {
    String openAIKey = await loadOpenAIKey();
    if (openAIKey.isEmpty) {
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTimestamp - _moochRequestTimestamp >= MOOCH_REQUEST_PERIOD) {
        await saveMoochRequestCount(1);
        await saveMoochRequestTimestamp(currentTimestamp);
        setState(() {
          _moochRequestCount = 1;
          _moochRequestTimestamp = currentTimestamp;
        });
      }
      if (_moochRequestCount > MAX_MOOCH_REQUESTS) {
        return false;
      }
    }
    return true;
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

  void _updatePrompts(List<Map<String, String>> updatedPrompts, String updatedSelectedPromptUuid) {
    setState(() {
      _prompts = updatedPrompts;
      _selectedPromptUuid = updatedSelectedPromptUuid;
    });
    savePrompts(_prompts);
    saveSelectedPromptUuid(_selectedPromptUuid);
  }

  void _onOpenAIKeyMissing() {
    if (ALLOW_USER_API_KEY) {
      showKeyDialog(context);
    }
  }

  void _handleInitialPrompt(String prompt, String title) {
    showAddPromptDialog(
      context,
      (title, prompt, _) {
        String newPromptId = uuid.v4();
        setState(() {
          _prompts.add({'id': newPromptId, 'title': title, 'prompt': prompt});
          _selectedPromptUuid = newPromptId;
        });
        savePrompts(_prompts);
        saveSelectedPromptUuid(_selectedPromptUuid);
      },
      initialPrompt: prompt,
      initialTitle: title,
    );
  }

  void _loadEngines() async {
    List<Map<String, String>> loadedEngines = await loadEngines();
    String loadedSelectedEngineId = await loadSelectedEngineId();
    setState(() {
      _engines = loadedEngines;
      _selectedEngineId = loadedSelectedEngineId;
    });
  }

  void _analyzeImage() async {
    String openAIKey = await loadOpenAIKey();
    bool canMakeRequest = openAIKey.isEmpty ? await _canMakeRequest() : true;

    if (!canMakeRequest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Quota Reached",
            style: TextStyle(
              color: Colors.white
            )
          ),
          content: Text(
            ALLOW_USER_API_KEY ?
            "Please either provision and add your own OpenAI API key (via the ⚙️ button on the top right) or try again later."
            :
            "Please try again later.",
            style: TextStyle(
              color: Colors.white
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white
                )
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (openAIKey.isEmpty) {
      _updateMoochRequestCount();
    }

    _audioManager.playRandomAudio();
    _cancelToken = CancelToken(); // Create a new CancelToken for each analysis
    _analyzeOperation = CancelableOperation.fromFuture(
      CameraFunctions.analyzePicture(
        _controller!,
        _prompts,
        _selectedPromptUuid,
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
        _onInvalidOpenAIKey,
        _isFlashOn,
        _cancelToken,
        _engines.firstWhere(
          (engine) => engine['id'] == _selectedEngineId,
          orElse: () {
            // Provide a fallback if no engine is found
            // You can also show an error message to the user here
            // For simplicity, we'll use the first engine as a default
            return _engines.first;
          },
        ),
      ),
    );
  }

  void _onInvalidOpenAIKey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Invalid API Key",
          style: TextStyle(
            color: Colors.white,
          )
        ),
        content: Text(
          ALLOW_USER_API_KEY ?
          "Invalid OpenAI API Key - please provision and set your own API key via the ⚙️ button in the top right or update this app."
          :
          "Please try updating this app.",
          style: TextStyle(
            color: Colors.white,
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
              )
            ),
          ),
        ],
      ),
    );
  }

  void _cancelAnalysis() {
    if (_analyzeOperation != null && !_analyzeOperation!.isCompleted) {
      _cancelToken.isCancellationRequested = true; // Set the cancellation flag
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

  void _addToFavorites() {
    if (_capturedImage != null) {
      String selectedPrompt = _prompts.firstWhere((prompt) => prompt['id'] == _selectedPromptUuid)['prompt']!;
      String selectedPromptTitle = _prompts.firstWhere((prompt) => prompt['id'] == _selectedPromptUuid)['title']!;
      FavoriteItem newFavorite = FavoriteItem(
        uuid: uuid.v4(),
        imageFile: _capturedImage!,
        response: _responseBody,
        promptTitle: selectedPromptTitle,
        prompt: selectedPrompt,
      );
      setState(() {
        _favorites.add(newFavorite);
      });
      saveFavorites(_favorites);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF4EFFB6),
          content: Text(
            'Response added to your faves ❤️',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )
          )
        ),
      );
    }
  }

  void _deleteFavorite(FavoriteItem favoriteItem) {
    setState(() {
      _favorites.remove(favoriteItem);
    });
    saveFavorites(_favorites);
  }

  Widget _buildScrollableResponseView({
    required File? imageFile,
    required String responseBody,
    required String prompt,
    required String promptTitle,
  }) {
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            thickness: 6.0,
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ResponseView(
                  imageFile: imageFile,
                  responseBody: responseBody,
                  prompt: prompt,
                  promptTitle: promptTitle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

    final selectedPrompt = _prompts.firstWhere((prompt) => prompt['id'] == _selectedPromptUuid, orElse: () => {'title': 'Select a Prompt'});
    final currentPromptTitle = selectedPrompt['title'];

    return Scaffold(
      key: _scaffoldKey,
      appBar: HomeAppBar(
        audioManager: _audioManager,
        onShowKeyDialog: () {
          showKeyDialog(context);
        },
        onResetPrompts: resetPrompts, // Pass the resetPrompts method
      ),
      body: Stack(
        children: [
          if (_initializeControllerFuture != null && !_isSwitchingCamera)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreviewWidget(
                    controller: _controller!,
                    capturedImage: _capturedImage,
                  );
                } else {
                  return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                }
              },
            ),
          if (_isAnalyzing)
            _buildScrollableResponseView(
              imageFile: _capturedImage,
              responseBody: _responseBody,
              prompt: selectedPrompt['prompt']!,
              promptTitle: selectedPrompt['title']!,
            ),
          if (!_isAnalyzing && _responseBody.isNotEmpty)
            _buildScrollableResponseView(
              imageFile: _capturedImage,
              responseBody: _responseBody,
              prompt: selectedPrompt['prompt']!,
              promptTitle: selectedPrompt['title']!,
            ),
          if (!_isAnalyzing && _responseBody.isEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 90,
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PromptButton(
                      onAnalyzePressed: _analyzeImage,
                      currentPromptTitle: currentPromptTitle!,
                      onPressed: () {
                        showPromptsDrawer(
                          context: context,
                          prompts: _prompts,
                          selectedPromptUuid: _selectedPromptUuid,
                          onPromptsUpdated: _updatePrompts,
                          onAnalyzePressed: _analyzeImage,
                          scaffoldKey: _scaffoldKey, // Pass the scaffold key
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        showPromptsDrawer(
                          context: context,
                          prompts: _prompts,
                          selectedPromptUuid: _selectedPromptUuid,
                          onPromptsUpdated: _updatePrompts,
                          onAnalyzePressed: _analyzeImage,
                          scaffoldKey: _scaffoldKey, // Pass the scaffold key
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Colors.deepPurple.shade700, width: 3),
                        ),
                        padding: EdgeInsets.all(13),
                        minimumSize: Size(60, 60), // Set a fixed size for the button
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      endDrawer: FavoritesDrawer(
        favorites: _favorites,
        onFavoriteItemTapped: (favoriteItem) {
          showDialog(
            context: context,
            builder: (context) => FavoriteItemDialog(favoriteItem: favoriteItem),
          );
        },
        onFavoriteItemDeleted: _deleteFavorite,
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
        openFavorites: () {
          _scaffoldKey.currentState?.openEndDrawer();
        },
        addToFavorites: _addToFavorites,
      ),
    );
  }
}
// eof

