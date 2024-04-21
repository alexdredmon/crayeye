// FILENAME: prompt_list_tile.dart
import 'package:flutter/material.dart';

class PromptListTile extends StatelessWidget {
  final Map<String, String> prompt;
  final bool isSelected;
  final Function(String) onEditPrompt;
  final Function(String) onDeletePrompt;
  final Function(String, String) onSharePrompt;
  final Function(String) onPromptTapped;

  const PromptListTile({
    Key? key,
    required this.prompt,
    required this.isSelected,
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
          color: isSelected ? Color(0xFF4EFFB6) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: PopupMenuButton<String>(
        color: Colors.black,
        onSelected: (String value) {
          switch (value) {
            case 'Edit':
              onEditPrompt(prompt['id']!);
              break;
            case 'Delete':
              onDeletePrompt(prompt['id']!);
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
              leading: Icon(Icons.edit, color: Colors.orangeAccent),
              title: Text('Edit', style: TextStyle(color: Colors.white)),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.redAccent),
              title: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Share',
            child: ListTile(
              leading: Icon(Icons.send, color: Colors.blueAccent),
              title: Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
        icon: const Icon(Icons.more_vert, color: Colors.white),
      ),
      onTap: () => onPromptTapped(prompt['id']!),
    );
  }
}
// eof
