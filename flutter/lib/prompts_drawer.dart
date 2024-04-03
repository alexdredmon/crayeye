// FILENAME: prompts_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prompt_dialogs.dart';
import 'key_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'config.dart';
import 'prompt_list_tile.dart';
import 'prompts_drawer_buttons.dart';
import 'prompts_drawer_methods.dart';

Future<void> showPromptsDrawer({
  required BuildContext context,
  required List<Map<String, String>> prompts,
  required String selectedPromptUuid,
  required Function(List<Map<String, String>>, String) onPromptsUpdated,
  required VoidCallback onAnalyzePressed,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    builder: (BuildContext context) {
      return PromptsDrawer(
        prompts: prompts,
        selectedPromptUuid: selectedPromptUuid,
        onPromptsUpdated: onPromptsUpdated,
        onAnalyzePressed: onAnalyzePressed,
      );
    },
  );
}

class PromptsDrawer extends StatefulWidget {
  final List<Map<String, String>> prompts;
  final String selectedPromptUuid;
  final Function(List<Map<String, String>>, String) onPromptsUpdated;
  final VoidCallback onAnalyzePressed;

  const PromptsDrawer({
    Key? key,
    required this.prompts,
    required this.selectedPromptUuid,
    required this.onPromptsUpdated,
    required this.onAnalyzePressed,
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
                  onPressed: () async {
                    bool confirm = await showResetPromptsConfirmationDialog(context);
                    if (confirm == true) {
                      PromptsDrawerMethods.resetPrompts(
                        prompts: _prompts,
                        onPromptsUpdated: widget.onPromptsUpdated,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                onReorder: (int oldIndex, int newIndex) {
                  PromptsDrawerMethods.reorderPrompts(
                    prompts: _prompts,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                    onPromptsUpdated: widget.onPromptsUpdated,
                  );
                },
                itemCount: _prompts.length,
                itemBuilder: (context, index) {
                  Map<String, String> prompt = _prompts[index];
                  return PromptListTile(
                    key: ValueKey(prompt),
                    prompt: prompt,
                    isSelected: prompt['id'] == widget.selectedPromptUuid,
                    onEditPrompt: (uuid) {
                      PromptsDrawerMethods.editPrompt(
                        context: context,
                        prompts: _prompts,
                        uuid: uuid,
                        onPromptsUpdated: widget.onPromptsUpdated,
                        selectedPromptUuid: widget.selectedPromptUuid,
                      );
                    },
                    onDeletePrompt: (uuid) async {
                      bool confirm = await showDeletePromptConfirmationDialog(context);
                      if (confirm == true) {
                        PromptsDrawerMethods.deletePrompt(
                          prompts: _prompts,
                          uuid: uuid,
                          onPromptsUpdated: widget.onPromptsUpdated,
                          selectedPromptUuid: widget.selectedPromptUuid,
                        );
                        Navigator.pop(context);
                      }
                    },
                    onSharePrompt: (title, prompt) {
                      Share.share('crayeye://app?title=$title&prompt=$prompt');
                    },
                    onPromptTapped: (uuid) {
                      widget.onPromptsUpdated(_prompts, uuid);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
          PromptsDrawerButtons(
            onShowKeyDialog: () {
              showKeyDialog(context);
            },
            onAddPrompt: () {
              PromptsDrawerMethods.addPrompt(
                context: context,
                prompts: _prompts,
                onPromptsUpdated: widget.onPromptsUpdated,
                selectedPromptUuid: widget.selectedPromptUuid,
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
// eof
