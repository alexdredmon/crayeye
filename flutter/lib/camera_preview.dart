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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 300,
        height: 300,
        child: capturedImage != null
            ? Image.file(capturedImage!)
            : CameraPreview(controller),
      ),
    );
  }
}
// eof
