// prompts_drawer.dart
import 'package:flutter/material.dart';

class PromptsDrawer extends StatelessWidget {
  final List<Map<String, String>> prompts;
  final Function(int) onEditPrompt;
  final Function(int) onDeletePrompt;
  final VoidCallback onAddPrompt;

  const PromptsDrawer({
    Key? key,
    required this.prompts,
    required this.onEditPrompt,
    required this.onDeletePrompt,
    required this.onAddPrompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prompts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: prompts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(prompts[index]['title']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditPrompt(index),
                      ),
                      if (prompts.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDeletePrompt(index),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAddPrompt,
            child: const Text('Add Prompt'),
          ),
        ],
      ),
    );
  }
}

// eof
