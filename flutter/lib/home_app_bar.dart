// FILENAME: home_app_bar.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'help_drawer.dart';
import 'settings_drawer.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AudioManager audioManager;
  final VoidCallback onShowKeyDialog;
  final Function(List<Map<String, String>>) onResetPrompts; // Update this line

  const HomeAppBar({
    Key? key,
    required this.audioManager,
    required this.onShowKeyDialog,
    required this.onResetPrompts, // Update this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.help, color: Colors.white),
        onPressed: () {
          showHelpDrawer(context);
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
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            showSettingsDrawer(context, audioManager, onShowKeyDialog, onResetPrompts); // Update this line
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
// eof
