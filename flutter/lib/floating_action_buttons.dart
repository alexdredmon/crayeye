// FILENAME: floating_action_buttons.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FloatingActionButtons extends StatelessWidget {
  final bool isAnalyzing;
  final String responseBody;
  final bool isFlashOn;
  final CameraLensDirection cameraDirection;
  final VoidCallback toggleFlash;
  final VoidCallback switchCamera;
  final VoidCallback cancelAnalysis;
  final VoidCallback startNewScan;
  final VoidCallback analyzeImage;
  final VoidCallback openFavorites;
  final VoidCallback addToFavorites;

  const FloatingActionButtons({
    Key? key,
    required this.isAnalyzing,
    required this.responseBody,
    required this.isFlashOn,
    required this.cameraDirection,
    required this.toggleFlash,
    required this.switchCamera,
    required this.cancelAnalysis,
    required this.startNewScan,
    required this.analyzeImage,
    required this.openFavorites,
    required this.addToFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isAnalyzing && responseBody.isEmpty)
          FloatingActionButton(
            backgroundColor: Color(0xFFff80ab),
            onPressed: openFavorites,
            child: Icon(Icons.favorite),
            shape: CircleBorder(), // This ensures the button is fully round
          ),
        if (!isAnalyzing && responseBody.isEmpty) const SizedBox(height: 16),
        if (!isAnalyzing && responseBody.isEmpty && cameraDirection == CameraLensDirection.back)
          FloatingActionButton(
            backgroundColor: Color(0xFF4EFFB6),
            onPressed: toggleFlash,
            child: Icon(
              isFlashOn ? Icons.flash_off : Icons.flash_on,
            ),
            shape: CircleBorder(), // This ensures the button is fully round
          ),
        if (!isAnalyzing && responseBody.isEmpty && cameraDirection == CameraLensDirection.back) const SizedBox(height: 16),
        if (!isAnalyzing && responseBody.isEmpty)
          FloatingActionButton(
            backgroundColor: Color(0xFF4EFFB6),
            onPressed: switchCamera,
            child: const Icon(Icons.cameraswitch),
            shape: CircleBorder(), // This ensures the button is fully round
          ),
        if (!isAnalyzing && responseBody.isEmpty) const SizedBox(height: 16),
        if (isAnalyzing)
          FloatingActionButton(
            onPressed: cancelAnalysis,
            backgroundColor: Colors.red,
            shape: CircleBorder(), // This ensures the button is fully round
            child: Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ),
        if (isAnalyzing) const SizedBox(height: 25),
        if (!isAnalyzing && responseBody.isNotEmpty)
          FloatingActionButton(
            onPressed: addToFavorites,
            backgroundColor: Color(0xFFff80ab),
            shape: CircleBorder(), // This ensures the button is fully round
            child: Icon(
              Icons.favorite,
              color: Colors.black,
            ),
          ),
        if (!isAnalyzing && responseBody.isNotEmpty) const SizedBox(height: 16),
        isAnalyzing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : responseBody.isNotEmpty
                ? FloatingActionButton(
                    backgroundColor: Colors.deepPurple.shade700,
                    onPressed: startNewScan,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                    shape: CircleBorder(), // This ensures the button is fully round
                  )
                : const SizedBox.shrink(),
        if (!isAnalyzing && responseBody.isEmpty) const SizedBox(height: 50),
        if (isAnalyzing) const SizedBox(height: 12),
      ],
    );
  }
}
// eof
