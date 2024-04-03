// FILENAME: home_app_bar.dart
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'help_drawer.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AudioManager audioManager;
  final VoidCallback toggleAudio;

  const HomeAppBar({
    Key? key,
    required this.audioManager,
    required this.toggleAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: ValueListenableBuilder<bool>(
        valueListenable: audioManager.isAudioEnabledNotifier,
        builder: (context, isAudioEnabled, child) {
          return IconButton(
            icon: Icon(
              isAudioEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: toggleAudio,
          );
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
