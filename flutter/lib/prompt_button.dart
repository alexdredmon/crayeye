// FILENAME: prompt_button.dart
import 'package:flutter/material.dart';

class PromptButton extends StatelessWidget {
  final String currentPromptTitle;
  final VoidCallback onPressed;

  const PromptButton({
    Key? key,
    required this.currentPromptTitle,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          const SizedBox(width: 8),
          const Icon(Icons.settings, color: Colors.white),
        ],
      ),
    );
  }
}
// eof
