// FILENAME: edit_engine_screen.dart
import 'package:flutter/material.dart';

class EditEngineScreen extends StatefulWidget {
  final Map<String, String> engine;
  final Function(Map<String, String>) onSave;

  EditEngineScreen({required this.engine, required this.onSave});

  @override
  _EditEngineScreenState createState() => _EditEngineScreenState();
}

class _EditEngineScreenState extends State<EditEngineScreen> {
  late TextEditingController _titleController;
  late TextEditingController _definitionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.engine['title']);
    _definitionController = TextEditingController(text: widget.engine['definition']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _definitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Engine', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(
                color: Color(0xFF4effb6),
                fontFamily: 'CourierPrime'
              ),
              controller: _definitionController,
              decoration: InputDecoration(labelText: 'Definition'),
              maxLines: 7,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final editedEngine = {
                  'id': widget.engine['id']!,
                  'title': _titleController.text,
                  'definition': _definitionController.text,
                };
                widget.onSave(editedEngine);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}
// eof
