// FILENAME: response_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return SingleChildScrollView(
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
            margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 200.0), // Add 100px of padding to the bottom
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
                const SizedBox(height: 8),
                MarkdownBody(
                  data: responseBody,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: TextStyle(color: Colors.white),
                  ),
                  onTapLink: (String text, String? href, String title) async {
                    if (href != null) {
                      if (await canLaunch(href)) {
                        await launch(href);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prompt:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
    );
  }
}
// eof
