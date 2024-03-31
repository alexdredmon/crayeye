// FILENAME: analysis_manager.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'camera_functions.dart';
import 'home_page.dart';

class AnalysisManager {
  static void startAnalysis({
    required CameraController controller,
    required List<Map<String, String>> prompts,
    required int selectedPromptIndex,
    required Function(File?, String, bool) onAnalysisComplete,
    required Function() onOpenAIKeyMissing,
    required MyHomePageState homePageState,
  }) {
    homePageState.playRandomAudio();
    CameraFunctions.analyzePicture(
      controller,
      prompts,
      selectedPromptIndex,
      (capturedImage, responseBody, isAnalyzing) {
        if (homePageState.isFlashOn) {
          homePageState.toggleFlash();
        }
        homePageState.updateAnalysisState(capturedImage, responseBody, isAnalyzing);
        if (!isAnalyzing) {
          homePageState.stopAudio();
        }
      },
      onOpenAIKeyMissing,
    );
  }
}
// eof
