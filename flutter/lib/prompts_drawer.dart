import 'package:flutter/material.dart';

class PromptsDrawer extends StatelessWidget {
  // ... (existing code remains the same)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (existing code remains the same)
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
          // ... (existing code remains the same)
        ],
      ),
    );
  }
}
