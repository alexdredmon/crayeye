// FILENAME: home_app_bar.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'help_drawer.dart';
import 'settings_drawer.dart'; // Add this import

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AudioManager audioManager;
  final VoidCallback toggleAudio;
  final VoidCallback onShowKeyDialog; // Add this line

  const HomeAppBar({
    Key? key,
    required this.audioManager,
    required this.toggleAudio,
    required this.onShowKeyDialog, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.white), // Replace volume icon with settings icon
        onPressed: () {
          showSettingsDrawer(context, audioManager, toggleAudio, onShowKeyDialog); // Open settings drawer
        },
      ),
      title: Center(
        child: Image(
          image: AssetImage('images/crayeye.png'),
          height: 30.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help, color: Colors.white),
          onPressed: () {
            showHelpDrawer(context);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
// eof
