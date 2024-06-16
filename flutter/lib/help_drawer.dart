// FILENAME: help_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

void showHelpDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final themeData = Theme.of(context);
      final baseTextStyle = TextStyle(color: Colors.white);
      return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(32.0),
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

You can create your own prompts or edit existing ones by tapping the ^ icon and selecting the pencil icon from the prompt's context menu.

You can check out (and add) featured prompts which demonstrate CrayEye's capabilities via the [Prompt Library](https://www.crayeye.com/prompts#library).

Responses are formatted in markdown, so you can use and request markdown in your prompts to control formatting and include links and images.

Your prompts can contain the following tokens which will be replaced with the respective real-time values from the user's device:

**Latitude:** {location.lat}

- *e.g. 40.7128*

**Longitude:** {location.long}

- *e.g. -74.0060*

**Date/Time:** {time.datetime}

- *e.g. Wednesday, October 29 1969 at 10:30pm*

**Temperature:** {weather.temp}

- *e.g. 75 degrees Fahrenheit*

**Weather Forecast:** {weather.forecast}

- *e.g. Partly cloudy with scattered showers, highs in the upper 70s.*

Additionally, you can use the following tokens to interpolate some handy animations (or specify your own image URLS via markdown syntax).

**GIFs:**

- {gif.yes}
![Yes](https://www.crayeye.com/img/app/yes.gif)

- {gif.no}
![No](https://www.crayeye.com/img/app/no.gif)

For more information visit [CrayEye.com](https://crayeye.com)
""",
                  styleSheet: MarkdownStyleSheet.fromTheme(themeData).copyWith(
                    textScaleFactor: 1.1,
                    p: baseTextStyle,
                    h1: baseTextStyle,
                    h2: baseTextStyle,
                    h3: baseTextStyle,
                    h4: baseTextStyle,
                    h5: baseTextStyle,
                    h6: baseTextStyle,
                    em: baseTextStyle,
                    strong: baseTextStyle,
                    blockquote: baseTextStyle,
                    img: baseTextStyle,
                    listBullet: baseTextStyle,
                    tableHead: baseTextStyle,
                    tableBody: baseTextStyle,
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 3.0, color: Colors.white)),
                    ),
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
            const SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}
// eof