// FILENAME: edit_engine_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';

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
    _definitionController = TextEditingController(
      text: _formatJsonString(widget.engine['definition']!),
    );
  }

  String _formatJsonString(String jsonString) {
    try {
      final parsedJson = json.decode(jsonString);
      final prettyJsonString = JsonEncoder.withIndent('  ').convert(parsedJson);
      return prettyJsonString;
    } catch (e) {
      return jsonString; // Return the original string if it's not valid JSON
    }
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(
                color: Color(0xFF4effb6),
                fontFamily: 'CourierPrime',
              ),
              controller: _definitionController,
              decoration: InputDecoration(
                labelText: 'Definition',
                labelStyle: TextStyle(color: Colors.white),
              ),
              maxLines: 7,
            ),
            SizedBox(height: 16),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Color(0xFF4effb6),
                    padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Color(0xFF4effb6), width: 3),
                    ),
                  ),
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
              ]
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}

// eof
