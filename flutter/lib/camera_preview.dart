// camera_preview.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final File? capturedImage;

  const CameraPreviewWidget({required this.controller, this.capturedImage});

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _getAspectRatio();
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: capturedImage != null
            ? Image.file(capturedImage!)
            : CameraPreview(controller),
      ),
    );
  }

  double _getAspectRatio() {
    // Use a fixed 3:4 aspect ratio for portrait orientation
    return 3 / 4;
  }
}
// eof
