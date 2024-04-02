// FILENAME: prompts_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prompt_dialogs.dart';
import 'key_dialog.dart';
import 'package:share_plus/share_plus.dart';

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
        onDeletePrompt: (index) {
          prompts.removeAt(index);
          if (selectedPromptIndex >= prompts.length) {
            selectedPromptIndex = prompts.length - 1;
          }
          onPromptsUpdated(prompts, selectedPromptIndex);
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
      );
    },
  );
}

class PromptsDrawer extends StatelessWidget {
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Prompts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              onReorder: onReorder,
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                Map<String, String> prompt = prompts[index];
                return ListTile(
                  key: ValueKey(prompt),
                  title: Text(
                    prompt['title']!,
                    style: TextStyle(
                      color: index == selectedPromptIndex ? Color(0xFF4EFFB6) : Colors.white,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: Colors.blueGrey.shade900,
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
                        child: Text('Edit', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Share',
                        child: Text('Share', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                  onTap: () => onPromptTapped(index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onShowKeyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueGrey.shade900,
                  ),
                  child: const Text('🔑 API Key'),
                ),
                ElevatedButton(
                  onPressed: onAddPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueGrey.shade900,
                  ),
                  child: const Text('➕ Add Prompt'),
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
