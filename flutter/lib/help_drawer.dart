// FILENAME: help_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

void showHelpDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.blueGrey.shade900,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: '# Help\n\nThis is some helpful help text! [CrayEye](https://crayeye.com)',
                  styleSheet: MarkdownStyleSheet(
                    textScaleFactor: 1.1,
                    p: TextStyle(color: Colors.white),
                    h1: TextStyle(color: Colors.white),
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
              ),
            ),
          ],
        ),
      );
    },
  );
}
// eof
