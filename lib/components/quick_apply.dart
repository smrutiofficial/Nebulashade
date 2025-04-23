import 'dart:io';
import 'package:flutter/material.dart';

List<String> colorCodes = [];
List<String> modifiedColorCodes = [];
List<int> selectedIndexes = [];
double hueShift = 0;
String originalCssContent = '';

Future<void> quickapplyTheme(
  // BuildContext context,
  // List<String> filePaths,
  // Future<void> Function() updateCssFileCallback,
) async {
  // if (!context.mounted) return;
  // Navigator.pop(context);
  // await updateCssFileCallback();
  final List<String> filePaths = [
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gtk-4.0/gtk.css',
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gtk-4.0/gtk-dark.css',
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gtk-3.0/gtk.css',
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gtk-3.0/gtk-dark.css',
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gnome-shell/gnome-shell.css',
    '${Platform.environment['HOME']}/.themes/Everforest-Dark-Soft-Adaptive/gnome-shell/pad-osd.css',
    '${Platform.environment['HOME']}/.config/gtk-4.0/gtk.css',
    '${Platform.environment['HOME']}/.config/gtk-4.0/gtk-dark.css',
  ];
  // Define new random or static colors
  final newMinimizeColor = "#e69875";
  final newMaximizeColor = "#a7c080";
  final newCloseColor = "#e67e80";

  for (var path in filePaths) {
    final file = File(path);
    if (await file.exists()) {
      // minimize
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.minimize:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newMinimizeColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.minimize:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.minimize:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // maximize------------------------
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.maximize:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newMaximizeColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.maximize:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color:shade($newMaximizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.maximize:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color:shade($newMaximizeColor, 0.6) ;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // close-----------------------------------
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.close:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newCloseColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.close:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.close:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);

      // gtk 3
      // ==============Close=================================================
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /windowcontrols button.close:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.close.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newCloseColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.close.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.close.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.close\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.close\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);

      // =================Minimize==========================================

      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.minimize.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newMinimizeColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.minimize.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.minimize.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.minimize\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.minimize\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);

      // ===============Maximize==============================================
      // await Process.run('bash', [
      //   '-c',
      //   '''
      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.maximize.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: $newMaximizeColor;");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.maximize.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button.maximize.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.maximize\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.maximize\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.6);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

      //   awk '
      //   BEGIN { in_block=0 }
      //   /button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:active, \\
      //   \\.background\\.csd\\.tiled headerbar\\.titlebar\\.default-decoration button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:hover, \\
      //   \\.background\\.csd\\.tiled headerbar\\.titlebar\\.default-decoration button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:active/ {
      //   in_block=1
      //   }
      //   in_block && /}/ { in_block=0 }
      //   in_block && /background-color:/ {
      //   sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
      //   }
      //   { print }
      //   ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
      //   '''
      // ]);
    }
  }

  // Run GNOME Shell theme temporary reset
  // await Process.run('bash', [
  //   '-c',
  //   "t=\$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d \"'\"); "
  //       "gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'; "
  //       "gsettings set org.gnome.shell.extensions.user-theme name \"\$t\""
  // ]);

  // Run GTK theme temporary reset
  // await Process.run('bash', [
  //   '-c',
  //   "t=\$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"'\"); "
  //       "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'; "
  //       "gsettings set org.gnome.desktop.interface gtk-theme \"\$t\""
  // ]);

  await Process.run('notify-send', [
    '-i',
    'dialog-information',
    '-a',
    'NebulaShade',
    '-u',
    'normal',
    '-t',
    '7000',
    'Theme Updated',
    'New Accent Colors ,GTK themes were refreshed!'
  ]);
}
