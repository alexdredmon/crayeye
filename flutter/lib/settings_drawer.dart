// FILENAME: settings_drawer.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'key_dialog.dart';

void showSettingsDrawer(BuildContext context, AudioManager audioManager, VoidCallback toggleAudio, VoidCallback onShowKeyDialog) {
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
              leading: ValueListenableBuilder<bool>(
                valueListenable: audioManager.isAudioEnabledNotifier,
                builder: (context, isAudioEnabled, child) {
                  return Icon(
                    isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  );
                },
              ),
              title: Text(
                'Mute/Unmute',
                style: TextStyle(color: Colors.white),
              ),
              onTap: toggleAudio,
            ),
            ListTile(
              leading: Icon(Icons.vpn_key, color: Colors.white),
              title: Text(
                'OpenAI API Key',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShowKeyDialog,
            ),
          ],
        ),
      );
    },
  );
}
// eof
