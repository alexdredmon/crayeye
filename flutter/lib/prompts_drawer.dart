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
import 'utils.dart';
import 'dart:convert';

Future<void> showPromptsDrawer({
  required BuildContext context,
  required List<Map<String, String>> prompts,
  required String selectedPromptUuid,
  required Function(List<Map<String, String>>, String) onPromptsUpdated,
  required VoidCallback onAnalyzePressed,
  required GlobalKey<ScaffoldState> scaffoldKey,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return PromptsDrawer(
        prompts: prompts,
        selectedPromptUuid: selectedPromptUuid,
        onPromptsUpdated: onPromptsUpdated,
        onAnalyzePressed: onAnalyzePressed,
        scaffoldKey: scaffoldKey,
      );
    },
  );
}

class PromptsDrawer extends StatefulWidget {
  final List<Map<String, String>> prompts;
  final String selectedPromptUuid;
  final Function(List<Map<String, String>>, String) onPromptsUpdated;
  final VoidCallback onAnalyzePressed;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const PromptsDrawer({
    Key? key,
    required this.prompts,
    required this.selectedPromptUuid,
    required this.onPromptsUpdated,
    required this.onAnalyzePressed,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  _PromptsDrawerState createState() => _PromptsDrawerState();
}

class _PromptsDrawerState extends State<PromptsDrawer> {
  late List<Map<String, String>> _prompts;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _prompts = List.from(widget.prompts);
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {});
  }

  void _updateSearchText(String searchText) {
    setState(() {
      _searchText = searchText;
      _searchController.text = searchText;
    });
  }

  void _clearSearchText() {
    setState(() {
      _searchText = '';
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  List<Map<String, String>> _getFilteredPrompts() {
    if (_searchText.isEmpty) {
      return _prompts;
    }
    return _prompts.where((prompt) => prompt['title']!.toLowerCase().contains(_searchText.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: _searchFocusNode.hasFocus ? 40 : 15, bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _searchFocusNode.hasFocus ? SizedBox.shrink() : Text(
                    'Prompts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  (! _searchFocusNode.hasFocus && _searchText != "") ? SizedBox(width: 10) : SizedBox.shrink(),
                  (! _searchFocusNode.hasFocus && _searchText != "") ? Text(
                    '>',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ) : SizedBox.shrink(),
                  (! _searchFocusNode.hasFocus && _searchText != "") ? SizedBox(width: 10) : SizedBox.shrink(),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _updateSearchText,
                      style: TextStyle(color: Colors.white),
                      // textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: _searchFocusNode.hasFocus ? 'Search prompts... ' : '',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        suffixIcon: _searchFocusNode.hasFocus
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white),
                                onPressed: _clearSearchText,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.black, // Background color
                                  borderRadius: BorderRadius.circular(100), // Rounded corners
                                ),
                                padding: EdgeInsets.all(8), // Padding inside the container
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              )
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Scrollbar(
                thickness: 6.0,
                thumbVisibility: true,
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  onReorder: (int oldIndex, int newIndex) {
                    PromptsDrawerMethods.reorderPrompts(
                      prompts: _prompts,
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                      onPromptsUpdated: (updatedPrompts, selectedUuid) {
                        setState(() {
                          _prompts = updatedPrompts;
                        });
                        widget.onPromptsUpdated(updatedPrompts, selectedUuid);
                      },
                    );
                  },
                  itemCount: _getFilteredPrompts().length,
                  itemBuilder: (context, index) {
                    Map<String, String> prompt = _getFilteredPrompts()[index];
                    return PromptListTile(
                      key: ValueKey(prompt),
                      prompt: prompt,
                      isSelected: prompt['id'] == widget.selectedPromptUuid,
                      onEditPrompt: (uuid) {
                        PromptsDrawerMethods.editPrompt(
                          context: context,
                          prompts: _prompts,
                          uuid: uuid,
                          onPromptsUpdated: (updatedPrompts, selectedUuid) {
                            setState(() {
                              _prompts = updatedPrompts;
                            });
                            widget.onPromptsUpdated(updatedPrompts, selectedUuid);
                          },
                          selectedPromptUuid: widget.selectedPromptUuid,
                        );
                      },
                      onDeletePrompt: (uuid) async {
                        bool confirm = await showDeletePromptConfirmationDialog(context);
                        if (confirm == true) {
                          PromptsDrawerMethods.deletePrompt(
                            prompts: _prompts,
                            uuid: uuid,
                            onPromptsUpdated: (updatedPrompts, selectedUuid) {
                              setState(() {
                                _prompts = updatedPrompts;
                              });
                              widget.onPromptsUpdated(updatedPrompts, selectedUuid);
                            },
                            selectedPromptUuid: widget.selectedPromptUuid,
                          );
                          Navigator.pop(context);
                        }
                      },
                      onSharePrompt: (title, prompt) {
                        String titleEncoded = Uri.encodeComponent(title);
                        String promptEncoded = Uri.encodeComponent(prompt);
                        String titleSlug = Uri.encodeComponent(title);

                        String shareUrl = 'crayeye://?title=$titleEncoded&prompt=$promptEncoded';
                        if (shareUrl.length > 300) {
                          shareUrl = '$title\n$prompt';
                        } else {
                          shareUrl = '$shareUrl\n\n$title\n$prompt';
                        }
                        Share.share(shareUrl);
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
              onAddPrompt: () {
                PromptsDrawerMethods.addPrompt(
                  context: context,
                  prompts: _prompts,
                  onPromptsUpdated: (updatedPrompts, selectedUuid) {
                    setState(() {
                      _prompts = updatedPrompts;
                    });
                    widget.onPromptsUpdated(updatedPrompts, selectedUuid);
                  },
                  selectedPromptUuid: widget.selectedPromptUuid,
                );
              },
              onClosePromptsDrawer: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
// eof
