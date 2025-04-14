import 'dart:io';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CssColorListScreen(),
  ));
}

class CssColorListScreen extends StatefulWidget {
  const CssColorListScreen({super.key});

  @override
  State<CssColorListScreen> createState() => _CssColorListScreenState();
}

class _CssColorListScreenState extends State<CssColorListScreen> {
  List<String> colorCodes = [];
  List<String> modifiedColorCodes = [];
  List<int> selectedIndexes = [];
  double hueShift = 0;
  String originalCssContent = '';
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

  @override
  void initState() {
    super.initState();
    extractColorsFromCss();
  }

  Future<void> extractColorsFromCss() async {
    final fileContents = await Future.wait(filePaths.map((path) async {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    }));

    if (fileContents.isEmpty) {
      print("No files found.");
      return;
    }

    final regex = RegExp(
      r'#(?:[0-9a-fA-F]{3}){1,2}|rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*(?:\d*\.\d+|\d+))?\s*\)',
      caseSensitive: false,
    );

    final matches = <String>{};
    for (var content in fileContents) {
      matches.addAll(regex.allMatches(content).map((m) => m.group(0)!));
    }

    // Simply return all the color matches without any exclusion
    setState(() {
      colorCodes = matches.toList();
      modifiedColorCodes = List.from(matches);
    });
  }

  Color? parseColor(String code) {
    try {
      if (code.startsWith('#')) {
        final hex = code.substring(1);
        if (hex.length == 3) {
          final r = hex[0] * 2;
          final g = hex[1] * 2;
          final b = hex[2] * 2;
          return Color(int.parse('FF$r$g$b', radix: 16));
        } else if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      } else if (code.startsWith('rgba')) {
        final values = code
            .replaceAll(RegExp(r'[rgba() ]'), '')
            .split(',')
            .map((s) => s.trim())
            .toList();

        final r = int.parse(values[0]);
        final g = int.parse(values[1]);
        final b = int.parse(values[2]);
        final a =
            values.length == 4 ? (double.parse(values[3]) * 255).toInt() : 255;

        return Color.fromARGB(a, r, g, b);
      } else if (code.startsWith('rgb')) {
        final values = code
            .replaceAll(RegExp(r'[rgb() ]'), '')
            .split(',')
            .map((s) => s.trim())
            .toList();

        final r = int.parse(values[0]);
        final g = int.parse(values[1]);
        final b = int.parse(values[2]);

        return Color.fromRGBO(r, g, b, 1.0);
      }
    } catch (_) {}
    return null;
  }

  bool isSimilarHue(Color a, Color b) {
    final hsvA = HSVColor.fromColor(a);
    final hsvB = HSVColor.fromColor(b);
    final diff = (hsvA.hue - hsvB.hue).abs();
    return diff < 30 || diff > 330;
  }

  String shiftHuePreservingFormat(String colorCode, double hueShift) {
    final color = parseColor(colorCode);
    if (color == null) return colorCode;

    final hsv = HSVColor.fromColor(color);
    final newHue = (hsv.hue + hueShift) % 360;
    final newColor = hsv.withHue(newHue).toColor();

    if (colorCode.startsWith('#')) {
      return '#${newColor.red.toRadixString(16).padLeft(2, '0')}${newColor.green.toRadixString(16).padLeft(2, '0')}${newColor.blue.toRadixString(16).padLeft(2, '0')}';
    } else if (colorCode.startsWith('rgba')) {
      return 'rgba(${newColor.red}, ${newColor.green}, ${newColor.blue}, ${(newColor.opacity).toStringAsFixed(2)})';
    } else if (colorCode.startsWith('rgb')) {
      return 'rgb(${newColor.red}, ${newColor.green}, ${newColor.blue})';
    }

    return colorCode;
  }

  Future<void> updateCssFile() async {
    for (var path in filePaths) {
      final file = File(path);
      if (await file.exists()) {
        String updatedContent = await file.readAsString();
        for (int i = 0; i < colorCodes.length; i++) {
          if (colorCodes[i] != modifiedColorCodes[i]) {
            updatedContent =
                updatedContent.replaceAll(colorCodes[i], modifiedColorCodes[i]);
          }
        }
        await file.writeAsString(updatedContent);
      }
    }
  }

  void onColorTap(int index) {
    final tappedColor = parseColor(modifiedColorCodes[index]);
    if (tappedColor == null) return;

    final similar = <int>[];
    for (int i = 0; i < colorCodes.length; i++) {
      final c = parseColor(modifiedColorCodes[i]);
      if (c != null && isSimilarHue(c, tappedColor)) {
        similar.add(i);
      }
    }

    setState(() {
      selectedIndexes = similar;
      hueShift = 0;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Adjust Hue",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: hueShift,
                  min: 0,
                  max: 360,
                  onChanged: (value) {
                    setModalState(() => hueShift = value);
                    setState(() {
                      for (var i in selectedIndexes) {
                        modifiedColorCodes[i] =
                            shiftHuePreservingFormat(colorCodes[i], hueShift);
                      }
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await updateCssFile();

                    // Define new random or static colors
                    final newMinimizeColor = "#e69875";
                    final newMaximizeColor = "#a7c080";
                    final newCloseColor = "#e67e80";

                    for (var path in filePaths) {
                      final file = File(path);
                      if (await file.exists()) {
                        // minimize
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.minimize:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: $newMinimizeColor;");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.minimize:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.minimize:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        // maximize------------------------
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.maximize:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: $newMaximizeColor;");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.maximize:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color:shade($newMaximizeColor, 0.4);");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.maximize:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color:shade($newMaximizeColor, 0.6) ;");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        // close-----------------------------------
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.close:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: $newCloseColor;");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.close:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);
                        await Process.run('bash', [
                          '-c',
                          '''
                          awk '
                          BEGIN { in_block=0 }
                          /windowcontrols button.close:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
                          in_block && /}/ { in_block=0 }
                          in_block && /background-color:/ {
                            sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
                          }
                          { print }
                          ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
                          '''
                        ]);

// gtk 3
// ==============Close=================================================
                        await Process.run('bash', [
                          '-c',
                          '''
  awk '
  BEGIN { in_block=0 }
  /windowcontrols button.close:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.close.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: $newCloseColor;");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.close.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.close.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.close\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.close\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newCloseColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
  '''
                        ]);

// =================Minimize==========================================

                        await Process.run('bash', [
                          '-c',
                          '''
  awk '
  BEGIN { in_block=0 }
  /button.minimize.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: $newMinimizeColor;");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.minimize.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.minimize.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.minimize\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.minimize\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMinimizeColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
  '''
                        ]);

// ===============Maximize==============================================
                        await Process.run('bash', [
                          '-c',
                          '''
  awk '
  BEGIN { in_block=0 }
  /button.maximize.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: $newMaximizeColor;");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.maximize.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button.maximize.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.maximize\\.titlebutton:hover:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /\\.background\\.csd headerbar\\.titlebar\\.default-decoration button\\.maximize\\.titlebutton:active:not\\(.suggested-action\\):not\\(.destructive-action\\)/ { in_block=1 }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.6);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"

  awk '
  BEGIN { in_block=0 }
  /button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:active, \\
  \\.background\\.csd\\.tiled headerbar\\.titlebar\\.default-decoration button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:hover, \\
  \\.background\\.csd\\.tiled headerbar\\.titlebar\\.default-decoration button\\.titlebutton:not\\(.suggested-action\\):not\\(.destructive-action\\)\\.maximize:active/ {
    in_block=1
  }
  in_block && /}/ { in_block=0 }
  in_block && /background-color:/ {
    sub(/background-color: .*/, "background-color: shade($newMaximizeColor, 0.4);");
  }
  { print }
  ' "$path" > "$path.tmp" && mv "$path.tmp" "$path"
  '''
                        ]);
                      }
                    }

                    // Run GNOME Shell theme temporary reset
                    await Process.run('bash', [
                      '-c',
                      "t=\$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d \"'\"); "
                          "gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'; "
                          "gsettings set org.gnome.shell.extensions.user-theme name \"\$t\""
                    ]);

                    // Run GTK theme temporary reset
                    await Process.run('bash', [
                      '-c',
                      "t=\$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"'\"); "
                          "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'; "
                          "gsettings set org.gnome.desktop.interface gtk-theme \"\$t\""
                    ]);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("CSS files updated and theme reloaded!")),
                    );
                  },
                  child: const Text("Apply and Save"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(
            "GTK CSS Colors",
            style: TextStyle(color: AppColors.accent),
          )),
      body: modifiedColorCodes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: modifiedColorCodes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final color = parseColor(modifiedColorCodes[index]);
                  if (color == null) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () => onColorTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
