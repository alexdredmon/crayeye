// FILENAME: prompts_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prompt_dialogs.dart';
import 'key_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'config.dart';

Future<void> showPromptsDrawer({
 required BuildContext context,
 required List<Map<String, String>> prompts,
 required int selectedPromptIndex,
 required Function(List<Map<String, String>>, int) onPromptsUpdated,
 required VoidCallback onAnalyzePressed,
}) async {
 await showModalBottomSheet(
   context: context,
   backgroundColor: Colors.blueGrey.shade900,
   builder: (BuildContext context) {
     return PromptsDrawer(
       prompts: prompts,
       selectedPromptIndex: selectedPromptIndex,
       onEditPrompt: (index) {
         showEditPromptDialog(
           context,
           index,
           prompts[index]['title']!,
           prompts[index]['prompt']!,
           (index, title, prompt) {
             prompts[index]['title'] = title;
             prompts[index]['prompt'] = prompt;
             onPromptsUpdated(prompts, selectedPromptIndex);
           },
           () {
             prompts.removeAt(index);
             onPromptsUpdated(prompts, selectedPromptIndex);
           },
         );
       },
       onDeletePrompt: (index) async {
         bool confirm = await showDialog(
           context: context,
           builder: (BuildContext context) {
             return AlertDialog(
               title: Text(
                 "Delete Prompt",
                 style: TextStyle(color: Colors.white),
               ),
               content: Text(
                 "Are you sure you want to delete this prompt?",
                 style: TextStyle(color: Colors.white),
               ),
               actions: [
                 TextButton(
                   child: Text(
                     "Cancel",
                     style: TextStyle(color: Colors.white),
                   ),
                   onPressed: () => Navigator.of(context).pop(false),
                 ),
                 ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.redAccent,
                     foregroundColor: Colors.white,
                   ),
                   child: Text("Delete"),
                   onPressed: () => Navigator.of(context).pop(true),
                 ),
               ],
             );
           },
         );
         if (confirm == true) {
           prompts.removeAt(index);
           if (selectedPromptIndex >= prompts.length) {
             selectedPromptIndex = prompts.length - 1;
           }
           onPromptsUpdated(prompts, selectedPromptIndex);
           Navigator.pop(context); // Close the drawer after selection
         }
       },
       onSharePrompt: (title, prompt) {
         Share.share('crayeye://app?title=$title&prompt=$prompt');
       },
       onAddPrompt: () {
         showAddPromptDialog(
           context,
           (title, prompt) {
             prompts.add({'title': title, 'prompt': prompt});
             onPromptsUpdated(prompts, selectedPromptIndex);
           },
         );
       },
       onShowKeyDialog: () {
         showKeyDialog(context);
       },
       onPromptTapped: (index) {
         selectedPromptIndex = index;
         onPromptsUpdated(prompts, selectedPromptIndex);
         Navigator.pop(context); // Close the drawer after selection
       },
       onAnalyzePressed: onAnalyzePressed,
       onReorder: (int oldIndex, int newIndex) {
         if (newIndex > oldIndex) {
           newIndex -= 1;
         }
         final item = prompts.removeAt(oldIndex);
         prompts.insert(newIndex, item);
         onPromptsUpdated(prompts, newIndex);
       },
       onResetPrompts: () async {
         bool confirm = await showDialog(
           context: context,
           builder: (BuildContext context) {
             return AlertDialog(
               title: Text(
                "Reset Prompts",
                style: TextStyle(color: Colors.white),
                ),
               content: Text(
                "Are you sure you want to reset all prompts to default?",
                style: TextStyle(color: Colors.white),
                ),
               actions: [
                 TextButton(
                   child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                    ),
                   onPressed: () => Navigator.of(context).pop(false),
                 ),
                 ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.redAccent,
                     foregroundColor: Colors.white,
                   ),  
                   child: Text("Reset"),
                   onPressed: () => Navigator.of(context).pop(true),
                 ),
               ],
             );
           },
         );
         if (confirm == true) {
           prompts.clear();
           prompts.addAll(defaultPrompts);
           selectedPromptIndex = 0;
           onPromptsUpdated(prompts, selectedPromptIndex);
           Navigator.pop(context); // Close the drawer after selection
         }
       },
     );
   },
 );
}

class PromptsDrawer extends StatefulWidget {
 final List<Map<String, String>> prompts;
 final int selectedPromptIndex;
 final Function(int) onEditPrompt;
 final Function(int) onDeletePrompt;
 final Function(String, String) onSharePrompt;
 final VoidCallback onAddPrompt;
 final VoidCallback onShowKeyDialog; 
 final Function(int) onPromptTapped;
 final VoidCallback onAnalyzePressed;
 final Function(int, int) onReorder;
 final VoidCallback onResetPrompts;

 const PromptsDrawer({
   Key? key,
   required this.prompts,
   required this.selectedPromptIndex,
   required this.onEditPrompt,
   required this.onDeletePrompt,  
   required this.onSharePrompt,
   required this.onAddPrompt,
   required this.onShowKeyDialog,
   required this.onPromptTapped,
   required this.onAnalyzePressed,
   required this.onReorder,
   required this.onResetPrompts,
 }) : super(key: key);

 @override
 _PromptsDrawerState createState() => _PromptsDrawerState();
}

class _PromptsDrawerState extends State<PromptsDrawer> {
 late List<Map<String, String>> _prompts;

 @override
 void initState() {
   super.initState();
   _prompts = List.from(widget.prompts);
 }

 void _onReorder(int oldIndex, int newIndex) {
   if (newIndex > oldIndex) {
     newIndex -= 1;
   }
   final item = _prompts.removeAt(oldIndex);
   _prompts.insert(newIndex, item);
   widget.onReorder(oldIndex, newIndex);
 }

 void _onDeletePrompt(int index) {
   setState(() {
     _prompts.removeAt(index);
   });
   widget.onDeletePrompt(index);
 }

 @override
 Widget build(BuildContext context) {
   return Container(
     padding: const EdgeInsets.all(0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Padding(
           padding: EdgeInsets.all(16.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 'Prompts',
                 style: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                 ),
               ),
               ElevatedButton(
                 onPressed: widget.onResetPrompts,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blueGrey.shade800,
                   foregroundColor: Colors.white,
                 ),  
                 child: Text('Reset'),
               ),
             ],
           ),
         ),
         Expanded(
           child: Scrollbar(
            thickness: 6.0,
            thumbVisibility: true,
             child: ReorderableListView.builder(
               onReorder: _onReorder,
               itemCount: _prompts.length,
               itemBuilder: (context, index) {
                 Map<String, String> prompt = _prompts[index];
                 return ListTile(
                   key: ValueKey(prompt),
                   title: Text(
                     prompt['title']!,
                     style: TextStyle(
                       color: index == widget.selectedPromptIndex ? Color(0xFF4EFFB6) : Colors.white,
                     ),  
                   ),
                   trailing: PopupMenuButton<String>(
                     color: Colors.blueGrey.shade800,
                     onSelected: (String value) {
                       switch (value) {
                         case 'Edit':
                           widget.onEditPrompt(index);
                           break;
                         case 'Delete':
                           widget.onDeletePrompt(index);
                           break;
                         case 'Share':
                           widget.onSharePrompt(prompt['title']!, prompt['prompt']!);
                           break;
                       }
                     },
                     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                       const PopupMenuItem<String>(
                         value: 'Edit',
                         child: ListTile(
                           leading: Icon(Icons.edit, color: Colors.white),
                           title: Text('Edit', style: TextStyle(color: Colors.white)),
                         ),
                       ),
                       const PopupMenuItem<String>(
                         value: 'Delete', 
                         child: ListTile(
                           leading: Icon(Icons.delete, color: Colors.white),
                           title: Text('Delete', style: TextStyle(color: Colors.white)),  
                         ),
                       ),
                       const PopupMenuItem<String>(
                         value: 'Share',
                         child: ListTile(
                           leading: Icon(Icons.share, color: Colors.white),
                           title: Text('Share', style: TextStyle(color: Colors.white)),
                         ),
                       ),
                     ],
                     icon: const Icon(Icons.more_vert, color: Colors.white),
                   ),
                   onTap: () => widget.onPromptTapped(index),
                 );
               },
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.all(16.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               ElevatedButton(
                 onPressed: widget.onShowKeyDialog,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white,
                   foregroundColor: Colors.blueGrey.shade900,
                 ),
                 child: const Text('🔑 API Key'),
               ),
               ElevatedButton(
                 onPressed: widget.onAddPrompt,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white, 
                   foregroundColor: Colors.blueGrey.shade900,
                 ),
                 child: const Text('➕ Prompt'),
               ),
             ],
           ),
         ),
         const SizedBox(height: 8),  
       ],
     ),
   );
 }
}
// eof
