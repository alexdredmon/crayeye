// FILENAME: prompts_drawer_buttons.dart
import 'package:flutter/material.dart';

class PromptsDrawerButtons extends StatelessWidget {
 final VoidCallback onShowKeyDialog;
 final VoidCallback onAddPrompt;

 const PromptsDrawerButtons({
   Key? key,
   required this.onShowKeyDialog,
   required this.onAddPrompt,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.all(16.0),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         ElevatedButton(
           onPressed: onShowKeyDialog,
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.white,
             foregroundColor: Colors.grey.shade900,
           ),
           child: const Text('🔑 API Key'),
         ),
         ElevatedButton(
           onPressed: onAddPrompt,
           style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4EFFB6),
              foregroundColor: Colors.black,
           ),
           child: const Text('➕ Prompt'),
         ),
       ],
     ),
   );
 }
}
// eof
