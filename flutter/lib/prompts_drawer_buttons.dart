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
             backgroundColor: Colors.black,
             foregroundColor: Colors.white,
           ),
           child: const Text('🔑 API'),
         ),
         // ElevatedButton(
         //   onPressed: onShowKeyDialog,
         //   style: ElevatedButton.styleFrom(
         //     backgroundColor: Colors.black,
         //     foregroundColor: Colors.white,
         //   ),
         //   child: const Text('❤️ Loved'),
         // ),
         ElevatedButton(
           onPressed: onAddPrompt,
           style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
           ),
           child: const Text('+ Prompt'),
         ),
       ],
     ),
   );
 }
}
// eof
