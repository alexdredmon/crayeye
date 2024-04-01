// FILENAME: prompts_drawer.dart
import 'package:flutter/material.dart';
import 'prompt_dialogs.dart';
import 'key_dialog.dart';
import 'dart:developer';

Future<void> showPromptsDrawer({
  required BuildContext context,
  required List<Map<String, String>> prompts,
  required int selectedPromptIndex,
  required Function(List<Map<String, String>>, int) onPromptsUpdated,
  String? initialPrompt,
  required VoidCallback onAnalyzePressed,
}) async {
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
            selectedPromptIndex: selectedPromptIndex,
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
                () {
                  setState(() {
                    prompts.removeAt(index);
                    if (selectedPromptIndex >= prompts.length) {
                      selectedPromptIndex = prompts.length - 1;
                    }
                  });
                  onPromptsUpdated(prompts, selectedPromptIndex);
                  Navigator.pop(context);
                },
              );
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
            onPromptTapped: (index) {
              onPromptsUpdated(prompts, index);
              Navigator.pop(context);
            },
            onAnalyzePressed: () {
              Navigator.pop(context); // Close the prompts drawer
              onAnalyzePressed();
            },
            onPromptsUpdated: onPromptsUpdated,
          );
        },
      );
    },
  );
}

class PromptsDrawer extends StatefulWidget {
  final List<Map<String, String>> prompts;
  final int selectedPromptIndex;
  final Function(int) onEditPrompt;
  final VoidCallback onAddPrompt;
  final VoidCallback onShowKeyDialog;
  final Function(int) onPromptTapped;
  final VoidCallback onAnalyzePressed;
  final Function(List<Map<String, String>>, int) onPromptsUpdated;

  const PromptsDrawer({
    Key? key,
    required this.prompts,
    required this.selectedPromptIndex,
    required this.onEditPrompt,
    required this.onAddPrompt,
    required this.onShowKeyDialog,
    required this.onPromptTapped,
    required this.onAnalyzePressed,
    required this.onPromptsUpdated,
  }) : super(key: key);

  @override
  _PromptsDrawerState createState() => _PromptsDrawerState();
}

class _PromptsDrawerState extends State<PromptsDrawer> {
  bool _isDragging = false;
  int _dragIndex = -1;

  void _startDragging(int index) {
    setState(() {
      _isDragging = true;
      _dragIndex = index;
    });
  }

  void _stopDragging() {
    setState(() {
      _isDragging = false;
      _dragIndex = -1;
    });
  }

  void _onDragFinish(int oldIndex, int newIndex) {
    log('$oldIndex');
    log('$newIndex');
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Map<String, String> draggedPrompt = widget.prompts.removeAt(oldIndex);
    widget.prompts.insert(newIndex, draggedPrompt);
    
    int newSelectedPromptIndex = widget.selectedPromptIndex;
    if (oldIndex == widget.selectedPromptIndex) {
      newSelectedPromptIndex = newIndex;
    } else if (oldIndex < widget.selectedPromptIndex && newIndex >= widget.selectedPromptIndex) {
      newSelectedPromptIndex -= 1;
    } else if (oldIndex > widget.selectedPromptIndex && newIndex <= widget.selectedPromptIndex) {
      newSelectedPromptIndex += 1;
    }
    
    widget.onPromptsUpdated(widget.prompts, newSelectedPromptIndex);
    _stopDragging();
  }

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
            child: Scrollbar(
              thumbVisibility: true, // This makes the scrollbar always visible
              thickness: 6.0,
              radius: Radius.circular(6.0),
              child: ReorderableListView(
                onReorder: _onDragFinish,
                children: widget.prompts.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> prompt = entry.value;
                  return Dismissible(
                    key: Key(prompt['title']!),
                    direction: _isDragging ? DismissDirection.none : DismissDirection.horizontal,
                    onDismissed: (direction) {
                      widget.onEditPrompt(index);
                    },
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () => widget.onPromptTapped(index),
                        // onLongPress: () => _startDragging(index),
                        // onLongPressEnd: (details) => _stopDragging(),
                        child: Row(
                          children: [
                            Text(
                              prompt['title']!,
                              style: TextStyle(
                                color: index == widget.selectedPromptIndex ? Color(0xFF4EFFB6) : Colors.white,
                                fontWeight: index == widget.selectedPromptIndex ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white), // Set icon color to white
                        onPressed: () => widget.onEditPrompt(index),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: widget.onShowKeyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.blueGrey.shade900, // Set button text color to blueGrey.shade900
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                child: const Text('🔑 API Key'),
              ),
              ElevatedButton(
                onPressed: widget.onAddPrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Set button background color to white
                  foregroundColor: Colors.blueGrey.shade900, // Set button text color to blueGrey.shade900
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                child: const Text('➕ Prompt'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
// eof
