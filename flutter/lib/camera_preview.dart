// FILENAME: camera_preview.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import statement

class DarkerImage extends StatelessWidget {
  final File imageFile;

  const DarkerImage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        1, 0, 0, 0, 0, // red channel
        0, 1, 0, 0, 0, // green channel
        0, 0, 1, 0, 0, // blue channel
        0, 0, 0, 1, -175, // apply a darker overlay
      ]),
      child: Image.file(imageFile),
    );
  }
}

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final File? capturedImage;

  const CameraPreviewWidget({required this.controller, this.capturedImage});

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);

    // Lock the camera's capture orientation
    controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

    return ClipRect(
      clipper: _MediaSizeClipper(mediaSize),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: capturedImage != null
            ? DarkerImage(imageFile: capturedImage!)
            : CameraPreview(controller),
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
// eof