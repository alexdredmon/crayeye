// FILENAME: prompt_list_tile.dart
import 'package:flutter/material.dart';

class PromptListTile extends StatelessWidget {
  final Map<String, String> prompt;
  final int index;
  final int selectedPromptIndex;
  final Function(int) onEditPrompt;
  final Function(int) onDeletePrompt;
  final Function(String, String) onSharePrompt;
  final Function(int) onPromptTapped;

  const PromptListTile({
    Key? key,
    required this.prompt,
    required this.index,
    required this.selectedPromptIndex,
    required this.onEditPrompt,
    required this.onDeletePrompt,
    required this.onSharePrompt,
    required this.onPromptTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(prompt),
      title: Text(
        prompt['title']!,
        style: TextStyle(
          color: index == selectedPromptIndex ? Color(0xFF4EFFB6) : Colors.white,
        ),  
      ),
      trailing: PopupMenuButton<String>(
        color: Colors.blueGrey.shade800,
        onSelected: (String value) {
          switch (value) {
            case 'Edit':
              onEditPrompt(index);
              break;
            case 'Delete':
              onDeletePrompt(index);
              break;
            case 'Share':
              onSharePrompt(prompt['title']!, prompt['prompt']!);
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
      onTap: () => onPromptTapped(index),
    );
  }
}
// eof
