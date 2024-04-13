// FILENAME: settings_drawer.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'key_dialog.dart';
import 'prompt_dialogs.dart';
import 'config.dart';

void showSettingsDrawer(BuildContext context, AudioManager audioManager, VoidCallback onShowKeyDialog) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.volume_up, color: Colors.grey),
              title: Text(
                'Volume',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => VolumeDialog(audioManager: audioManager),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.vpn_key, color: Colors.greenAccent),
              title: Text(
                'OpenAI API Key',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShowKeyDialog,
            ),
            ListTile(
              leading: Icon(Icons.restart_alt, color: Colors.redAccent),
              title: Text(
                'Reset Prompts',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                bool confirm = await showResetPromptsConfirmationDialog(context);
                if (confirm == true) {
                  List<Map<String, String>> defaultPromptsList = defaultPrompts.map((prompt) => Map<String, String>.from(prompt)).toList();
                  await savePrompts(defaultPromptsList);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

class VolumeDialog extends StatefulWidget {
  final AudioManager audioManager;

  const VolumeDialog({Key? key, required this.audioManager}) : super(key: key);

  @override
  _VolumeDialogState createState() => _VolumeDialogState();
}

class _VolumeDialogState extends State<VolumeDialog> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.audioManager.getVolume();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        'Volume',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
              widget.audioManager.setVolume(_volume);
            },
            activeColor: Colors.grey,
            inactiveColor: Colors.grey.shade700,
          ),
          SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: widget.audioManager.isAudioEnabledNotifier,
            builder: (context, isAudioEnabled, child) {
              return ElevatedButton.icon(
                onPressed: () {
                  if (isAudioEnabled) {
                    widget.audioManager.disableAudio();
                    widget.audioManager.stopAudio();
                  } else {
                    widget.audioManager.enableAudio();
                  }
                },
                icon: Icon(isAudioEnabled ? Icons.volume_up : Icons.volume_off),
                label: Text(isAudioEnabled ? 'Mute' : 'Unmute'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAudioEnabled ? Colors.grey : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
// eof
