// FILENAME: prompts_drawer_buttons.dart
import 'package:flutter/material.dart';

class PromptsDrawerButtons extends StatelessWidget {
  final VoidCallback onAddPrompt;
  final VoidCallback onClosePromptsDrawer;

  const PromptsDrawerButtons({
    Key? key,
    required this.onAddPrompt,
    required this.onClosePromptsDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: onAddPrompt,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Color(0xFF4effb6),
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Color(0xFF4effb6), width: 3),
              ),
            ),
            child: const Text('+ Prompt'),
          ),
          ElevatedButton(
            onPressed: onClosePromptsDrawer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.deepPurple.shade700, width: 3),
              ),
              padding: EdgeInsets.all(13),
              minimumSize: Size(30, 30), // Set a fixed size for the button
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// eof
