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
  final VoidCallback openSettings;

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
    required this.openSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isAnalyzing && responseBody.isEmpty && cameraDirection == CameraLensDirection.back)
          FloatingActionButton(
            backgroundColor: Color(0xFF4EFFB6),
            onPressed: toggleFlash,
            child: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
          ),
        if (!isAnalyzing && responseBody.isEmpty && cameraDirection == CameraLensDirection.back) const SizedBox(height: 16),
        if (!isAnalyzing && responseBody.isEmpty)
          FloatingActionButton(
            backgroundColor: Color(0xFF4EFFB6),
            onPressed: switchCamera,
            child: const Icon(Icons.cameraswitch),
          ),
        if (!isAnalyzing && responseBody.isEmpty) const SizedBox(height: 16),
        if (isAnalyzing)
          FloatingActionButton(
            onPressed: cancelAnalysis,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ),
        if (isAnalyzing) const SizedBox(height: 16),
        isAnalyzing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : FloatingActionButton(
                backgroundColor: responseBody.isNotEmpty ? Colors.deepPurple.shade700 : Colors.black,
                onPressed: responseBody.isNotEmpty
                    ? startNewScan
                    : openSettings,
                child: Icon(responseBody.isNotEmpty
                    ? Icons.arrow_back
                    : Icons.settings,
                    color: Colors.white),
              ),
        if (!isAnalyzing && responseBody.isEmpty) const SizedBox(height: 50),
      ],
    );
  }
}
// eof
