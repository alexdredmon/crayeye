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
        title: Text('Add Engine', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(
                color: Color(0xFF4effb6),
                fontFamily: 'CourierPrime'
              ),
              controller: _definitionController,
              decoration: InputDecoration(labelText: 'Definition', labelStyle: TextStyle(color: Colors.white)),
              maxLines: 7,
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
      backgroundColor: Colors.grey.shade900,
    );
  }
}
// eof
