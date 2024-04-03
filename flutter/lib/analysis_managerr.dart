// FILENAME: analysis_manager.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'camera_functions.dart';
import 'home_page.dart';
import 'response_notifier.dart';

class AnalysisManager {
  static void startAnalysis({
    required CameraController controller,
    required List<Map<String, String>> prompts,
    required int selectedPromptIndex,
    required Function(File?, String, bool) onAnalysisComplete,
    required Function() onOpenAIKeyMissing,
    required MyHomePageState homePageState,
    required ResponseNotifier responseNotifier,
  }) {
    homePageState.playRandomAudio();
    CameraFunctions.analyzePicture(
      controller,
      prompts,
      selectedPromptIndex,
      (capturedImage, isAnalyzing) {
        if (homePageState.isFlashOn) {
          homePageState.toggleFlash();
        }
        homePageState.updateAnalysisState(capturedImage, isAnalyzing);
        if (!isAnalyzing) {
          homePageState.stopAudio();
        }
      },
      responseNotifier,
      onOpenAIKeyMissing,
    );
  }
}
// eof
