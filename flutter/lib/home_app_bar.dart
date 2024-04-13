// FILENAME: home_app_bar.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'help_drawer.dart';
import 'settings_drawer.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AudioManager audioManager;
  final VoidCallback onShowKeyDialog;

  const HomeAppBar({
    Key? key,
    required this.audioManager,
    required this.onShowKeyDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.white),
        onPressed: () {
          showSettingsDrawer(context, audioManager, onShowKeyDialog);
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
