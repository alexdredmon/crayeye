// FILENAME: prompt_button.dart
import 'package:flutter/material.dart';

class PromptButton extends StatelessWidget {
  final String currentPromptTitle;
  final VoidCallback onPressed;
  final VoidCallback onAnalyzePressed;

  const PromptButton({
    Key? key,
    required this.currentPromptTitle,
    required this.onPressed,
    required this.onAnalyzePressed,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: currentPromptTitle == 'Select a Prompt' ? onPressed : onAnalyzePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentPromptTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
// eof
