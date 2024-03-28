// response_view.dart

import 'dart:io';
import 'package:flutter/material.dart';

class ResponseView extends StatelessWidget {
  final File? imageFile;
  final String responseBody;
  final String prompt;

  const ResponseView({
    Key? key,
    required this.imageFile,
    required this.responseBody,
    required this.prompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.file(imageFile!),
                ),
              ),
            Container(
              margin: const EdgeInsets.all(16.0), // Add margin around the container
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analysis Complete:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Add some spacing
                  Text(
                    responseBody,
                    style: TextStyle(
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                  const SizedBox(height: 16), // Add some spacing
                  const Text(
                    'Prompt:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Add some spacing
                  Text(
                    prompt,
                    style: TextStyle(
                      color: Colors.blueGrey.shade100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// eof