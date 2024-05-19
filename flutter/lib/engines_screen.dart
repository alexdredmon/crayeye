// FILENAME: engines_screen.dart
import 'package:flutter/material.dart';
import 'config.dart';
import 'edit_engine_screen.dart';
import 'add_engine_screen.dart';

class EnginesScreen extends StatefulWidget {
  @override
  _EnginesScreenState createState() => _EnginesScreenState();
}

class _EnginesScreenState extends State<EnginesScreen> {
  List<Map<String, String>> _engines = [];
  String _selectedEngineId = '';

  @override
  void initState() {
    super.initState();
    _loadEngines();
  }

  void _loadEngines() async {
    List<Map<String, String>> loadedEngines = await loadEngines();
    String loadedSelectedEngineId = await loadSelectedEngineId();
    setState(() {
      _engines = loadedEngines;
      _selectedEngineId = loadedSelectedEngineId;
    });
  }

  void _updateEngines(List<Map<String, String>> updatedEngines, String updatedSelectedEngineId) {
    setState(() {
      _engines = updatedEngines;
      _selectedEngineId = updatedSelectedEngineId;
    });
    saveEngines(_engines);
    saveSelectedEngineId(_selectedEngineId);
  }

  void _editEngine(String engineId) {
    final engine = _engines.firstWhere((engine) => engine['id'] == engineId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEngineScreen(
          engine: engine, // Update this line
          onSave: (editedEngine) {
            setState(() {
              final index = _engines.indexWhere((engine) => engine['id'] == editedEngine['id']);
              _engines[index] = editedEngine;
            });
            saveEngines(_engines);
          },
        ),
      ),
    );
  }

  void _deleteEngine(String engineId) async {
    if (_engines.length <= 1) {
      return; // Don't allow deleting if there's only one engine
    }

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Engine', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this engine?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.grey.shade900,
      ),
    );

    if (confirm == true) {
      setState(() {
        _engines.removeWhere((engine) => engine['id'] == engineId);
        if (_selectedEngineId == engineId) {
          _selectedEngineId = _engines.first['id']!;
        }
      });
      saveEngines(_engines);
      saveSelectedEngineId(_selectedEngineId);
    }
  }

  void _addEngine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEngineScreen(
          onSave: (newEngine) {
            setState(() {
              _engines.add(newEngine);
              _selectedEngineId = newEngine['id']!;
            });
            saveEngines(_engines);
            saveSelectedEngineId(_selectedEngineId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Engines', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _engines.length,
        itemBuilder: (context, index) {
          final engine = _engines[index];
          final isSelected = engine['id'] == _selectedEngineId;
          return ListTile(
            title: Text(
              engine['title']!,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: Colors.black,
              onSelected: (value) {
                if (value == 'Edit') {
                  _editEngine(engine['id']!);
                } else if (value == 'Delete') {
                  _deleteEngine(engine['id']!);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.orangeAccent),
                    title: Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                ),
                if (_engines.length > 1)
                  PopupMenuItem(
                    value: 'Delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.redAccent),
                      title: Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
              icon: Icon(Icons.more_vert, color: Colors.white),
            ),
            onTap: () {
              setState(() {
                _selectedEngineId = engine['id']!;
              });
              saveSelectedEngineId(_selectedEngineId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEngine,
        backgroundColor: Color(0xFF4effb6),
        child: Icon(Icons.add, color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}
// eof