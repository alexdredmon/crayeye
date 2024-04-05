// FILENAME: prompts_drawer_buttons.dart
import 'package:flutter/material.dart';

class PromptsDrawerButtons extends StatelessWidget {
  final VoidCallback onAddPrompt;
  final VoidCallback onClosePromptsDrawer; // Add this line

  const PromptsDrawerButtons({
    Key? key,
    required this.onAddPrompt,
    required this.onClosePromptsDrawer, // Add this line
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
            ),
            child: const Text('+ Prompt'),
          ),
          ElevatedButton(
            onPressed: onClosePromptsDrawer, // Update this line
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
            ),
          ),
        ],
      ),
    );
  }
}
// eof
