// response_view.dart
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
                    styleSheet: MarkdownStyleSheet(
                      textScaleFactor: 1.1,
                      p: TextStyle(color: Colors.white),
                      h1: TextStyle(color: Colors.white),
                      h2: TextStyle(color: Colors.white),
                      h3: TextStyle(color: Colors.white),
                      h4: TextStyle(color: Colors.white),
                      h5: TextStyle(color: Colors.white),
                      h6: TextStyle(color: Colors.white),
                      em: TextStyle(color: Colors.white),
                      strong: TextStyle(color: Colors.white),
                      del: TextStyle(color: Colors.white),
                      blockquote: TextStyle(color: Colors.white),
                      img: TextStyle(color: Colors.white),
                      checkbox: TextStyle(color: Colors.white),
                      blockSpacing: 8.0,
                      listIndent: 24.0,
                      listBullet: TextStyle(color: Colors.white),
                      listBulletPadding: EdgeInsets.only(right: 4.0),
                      code: TextStyle(color: Colors.white),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.blueGrey.shade700,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      codeblockPadding: EdgeInsets.all(8.0),
                      horizontalRuleDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 2.0),
                        ),
                      ),
                      tableHead: TextStyle(color: Colors.white),
                      tableBody: TextStyle(color: Colors.white),
                      tableHeadAlign: TextAlign.center,
                      tableBorder: TableBorder.all(color: Colors.white),
                      tableColumnWidth: const FlexColumnWidth(),
                      tableCellsPadding: EdgeInsets.all(8.0),
                      a: TextStyle(color: Colors.blue),
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
      ),
    );
  }
}
// eof
