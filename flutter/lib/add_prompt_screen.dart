// FILENAME: add_prompt_screen.dart
import 'package:flutter/material.dart';

class AddPromptScreen extends StatefulWidget {
  final Function(String, String, String) onSave;
  final String? initialPrompt;
  final String? initialTitle;

  const AddPromptScreen({
    Key? key,
    required this.onSave,
    this.initialPrompt,
    this.initialTitle,
  }) : super(key: key);

  @override
  _AddPromptScreenState createState() => _AddPromptScreenState();
}

class _AddPromptScreenState extends State<AddPromptScreen> {
  late TextEditingController _titleController;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _promptController = TextEditingController(text: widget.initialPrompt ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Prompt', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // Add this line
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
              maxLength: 28,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _promptController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Prompt',
                labelStyle: TextStyle(color: Colors.white),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Color(0xFFff80ab),
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Color(0xFFff80ab), width: 3),
                    ),
                  ),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_titleController.text, _promptController.text, '');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Color(0xFF4effb6),
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Color(0xFF4effb6), width: 3),
                    ),
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}
// eof
