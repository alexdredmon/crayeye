// FILENAME: add_engine_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class AddEngineScreen extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  AddEngineScreen({required this.onSave});

  @override
  _AddEngineScreenState createState() => _AddEngineScreenState();
}

class _AddEngineScreenState extends State<AddEngineScreen> {
  final _titleController = TextEditingController();
  final _definitionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              decoration: InputDecoration(labelText: 'Definition'),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newEngine = {
                  'id': uuid.v4(),
                  'title': _titleController.text,
                  'definition': _definitionController.text,
                };
                widget.onSave(newEngine);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
// eof
