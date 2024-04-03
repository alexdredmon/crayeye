// FILENAME: response_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ResponseView extends StatelessWidget {
  final File? imageFile;
  final String responseBody;
  final String prompt;
  final String promptTitle;


  const ResponseView({
    Key? key,
    required this.imageFile,
    required this.responseBody,
    required this.prompt,
    required this.promptTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          promptTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          prompt,
          style: TextStyle(
            color: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
// eof