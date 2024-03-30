// prompts_drawer.dart
import 'package:flutter/material.dart';
import 'prompt_dialogs.dart';
import 'key_dialog.dart';

Future<void> showPromptsDrawer({
  required BuildContext context,
  required List<Map<String, String>> prompts,
  required Function(List<Map<String, String>>, int) onPromptsUpdated,
  String? initialPrompt,
}) async {
  int selectedPromptIndex = 0;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.blueGrey.shade900, // Set background color
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          if (initialPrompt != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAddPromptDialog(
                context,
                (title, prompt) {
                  setState(() {
                    prompts.add({'title': title, 'prompt': prompt});
                  });
                  onPromptsUpdated(prompts, selectedPromptIndex);
                  Navigator.pop(context);
                },
                initialPrompt: initialPrompt,
              );
            });
          }

          return PromptsDrawer(
            prompts: prompts,
            onEditPrompt: (index) {
              showEditPromptDialog(
                context,
                index,
                prompts[index]['title']!,
                prompts[index]['prompt']!,
                (index, title, prompt) {
                  setState(() {
                    prompts[index]['title'] = title;
                    prompts[index]['prompt'] = prompt;
                  });
                },
              );
            },
            onDeletePrompt: (index) {
              setState(() {
                prompts.removeAt(index);
                if (selectedPromptIndex >= prompts.length) {
                  selectedPromptIndex = prompts.length - 1;
                }
              });
              onPromptsUpdated(prompts, selectedPromptIndex);
              Navigator.pop(context);
            },
            onAddPrompt: () {
              showAddPromptDialog(
                context,
                (title, prompt) {
                  setState(() {
                    prompts.add({'title': title, 'prompt': prompt});
                  });
                  onPromptsUpdated(prompts, selectedPromptIndex);
                },
              );
            },
            onShowKeyDialog: () {
              showKeyDialog(context);
            },
          );
        },
      );
    },
  );
}

class PromptsDrawer extends StatelessWidget {
  final List<Map<String, String>> prompts;
  final Function(int) onEditPrompt;
  final Function(int) onDeletePrompt;
  final VoidCallback onAddPrompt;
  final VoidCallback onShowKeyDialog;

  const PromptsDrawer({
    Key? key,
    required this.prompts,
    required this.onEditPrompt,
    required this.onDeletePrompt,
    required this.onAddPrompt,
    required this.onShowKeyDialog,
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
              color: Colors.white, // Set text color to white
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: prompts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    prompts[index]['title']!,
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white), // Set icon color to white
                        onPressed: () => onEditPrompt(index),
                      ),
                      if (prompts.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white), // Set icon color to white
                          onPressed: () => onDeletePrompt(index),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onAddPrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.blueGrey.shade900, // Set button text color to blueGrey.shade900
                ),
                child: const Text('Add Prompt'),
              ),
              ElevatedButton(
                onPressed: onShowKeyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.blueGrey.shade900, // Set button text color to blueGrey.shade900
                ),
                child: const Text('API Key'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// eof
