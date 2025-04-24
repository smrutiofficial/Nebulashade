import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:nebulashade/constants/colours.dart'; // Import your AppColors file

class AppColorsNotifier extends ValueNotifier<Color> {
  AppColorsNotifier(Color value) : super(value);

  late File _file;
  StreamSubscription<FileSystemEvent>? _watcher;

  void startWatching() {
    final home = Platform.environment['HOME'];
    if (home == null) {
      print("HOME environment variable not found.");
      return;
    }

    _file = File('$home/.config/gtk-4.0/gtk.css');

    if (!_file.existsSync()) {
      print("GTK theme file not found.");
      return;
    }

    _watcher = _file.parent.watch().listen((event) {
      if (event.path == _file.path &&
          (event is FileSystemModifyEvent || event is FileSystemCreateEvent)) {
        AppColors.init();
        value = AppColors.background;
      }
    });
  }

  @override
  void dispose() {
    _watcher?.cancel();
    super.dispose();
  }
}
