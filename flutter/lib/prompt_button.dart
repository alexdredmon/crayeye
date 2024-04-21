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
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black; // Background color when button is pressed
            }
            return Colors.deepPurple.shade700; // Default background color
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white; // Text color when button is pressed
            }
            return Colors.white; // Default text color
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
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
