import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

void showSharePromptDialog({
  required BuildContext context,
  required String title,
  required String prompt,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Prompt:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.lightBlue[200], // Matching color to "+ Prompt" button
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5), // Add margin between the title and the first button
            ElevatedButton(
              onPressed: () {
                String titleEncoded = Uri.encodeComponent(title);
                String promptEncoded = Uri.encodeComponent(prompt);
                String link = 'https://www.crayeye.com/link?title=$titleEncoded&prompt=$promptEncoded';
                Share.share(link);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: Colors.deepPurple.shade700, width: 3),
                ),
              ),
              child: Text('Share via URL', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String shareText = '$title\n$prompt';
                Share.share(shareText);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: Colors.deepPurple.shade700, width: 3),
                ),
              ),
              child: Text('Share prompt text', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade900,
      );
    },
  );
}
// eof