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
                  data: """
CrayEye is a sensor analysis multitool which uses input from your camera, GPS, and other available sensors
to execute customizable and user defined prompts against a multimodal large language model.

You can create your own prompts or edit existing ones by clicking the settings icon (edit a prompt via the pencil icon).

Your prompts can contain the following tokens which will be replaced with the respective real-time values from the user's device:

**Latitude:** {location.lat}

*e.g. 40.7128*

**Longitude:** {location.long}

*e.g. -74.0060*

**Orientation:** {location.orientation}

*e.g. west*

For more information visit [CrayEye.com](https://crayeye.com)
""",
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
