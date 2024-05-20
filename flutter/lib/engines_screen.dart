// FILENAME: engines_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'edit_engine_screen.dart';
import 'add_engine_screen.dart';
import 'engine_notifier.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

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

    var engineNotifier = Provider.of<EngineNotifier>(context, listen: false);
    var initialEngine = loadedEngines.firstWhere((engine) => engine['id'] == loadedSelectedEngineId, orElse: () => loadedEngines.first);
    engineNotifier.setEngine(initialEngine);
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
          engine: engine,
          onSave: (editedEngine) {
            setState(() {
              final index = _engines.indexWhere((engine) => engine['id'] == editedEngine['id']);
              _engines[index] = editedEngine;
              if (_selectedEngineId == editedEngine['id']) {
                _updateEngines(_engines, _selectedEngineId);
              }
            });
            saveEngines(_engines);
            var engineNotifier = Provider.of<EngineNotifier>(context, listen: false);
            engineNotifier.setEngine(editedEngine);
          },
        ),
      ),
    );
  }

  void _deleteEngine(String engineId) async {
    if (_engines.length <= 1) {
      return;
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
            var engineNotifier = Provider.of<EngineNotifier>(context, listen: false);
            engineNotifier.setEngine(newEngine);
          },
        ),
      ),
    );
  }

  void _resetEngines() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Engines', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to reset engine settings to system defaults?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.grey.shade900,
      ),
    );

    if (confirm == true) {
      List<Map<String, String>> defaultEnginesList = defaultEngines.map((engine) => Map<String, String>.from(engine)).toList();
      await saveEngines(defaultEnginesList);
      await saveSelectedEngineId(defaultEnginesList.first['id']!);
      setState(() {
        _engines = defaultEnginesList;
        _selectedEngineId = defaultEnginesList.first['id']!;
      });

      var engineNotifier = Provider.of<EngineNotifier>(context, listen: false);
      engineNotifier.setEngine(defaultEnginesList.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final baseTextStyle = TextStyle(color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        title: Text('Engines', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child:
              MarkdownBody(
                data: "Configure custom engines via Open API specification, e.g. connect to locally hosted / development models.  \n\nFor more information view Swagger docs via [https://swagger.io/specification](https://swagger.io/specification)",
                styleSheet: MarkdownStyleSheet.fromTheme(themeData).copyWith(
                  p: baseTextStyle,
                  h1: baseTextStyle,
                  h2: baseTextStyle,
                  h3: baseTextStyle,
                  h4: baseTextStyle,
                  h5: baseTextStyle,
                  h6: baseTextStyle,
                  em: baseTextStyle,
                  strong: baseTextStyle,
                  blockquote: baseTextStyle,
                  img: baseTextStyle,
                  listBullet: baseTextStyle,
                  tableHead: baseTextStyle,
                  tableBody: baseTextStyle,
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(top: BorderSide(width: 3.0, color: Colors.white)),
                  ),
                ),
                onTapLink: (String text, String? href, String title) async {
                  if (href != null) {
                    if (await canLaunch(href)) {
                      await launch(href);
                    }
                  }
                },
              ),
          ),
          
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _engines.length,
              itemBuilder: (context, index) {
                final engine = _engines[index];
                final isSelected = engine['id'] == _selectedEngineId;
                final isSystemEngine = engine.containsKey('origin') && engine['origin'] == 'system';

                return ListTile(
                  title: Text(
                    engine['title']!,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF4EFFB6) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSystemEngine
                      ? null
                      : PopupMenuButton<String>(
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
                    (context as Element).reassemble();
                    var engineNotifier = Provider.of<EngineNotifier>(context, listen: false);
                    engineNotifier.setEngine(engine);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _resetEngines,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Color(0xFFff80ab),
                        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Color(0xFFff80ab), width: 3),
                        ),
                      ),
                      child: Text('Reset to Defaults'),
                    ),
                    ElevatedButton(
                      onPressed: _addEngine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Color(0xFF4effb6),
                        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Color(0xFF4effb6), width: 3),
                        ),
                      ),
                      child: Text('+ Engine'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade900,
    );
  }
}
// eof