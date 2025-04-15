import 'dart:io';
import 'package:flutter/material.dart';

class BackgroundColorGrid extends StatefulWidget {
  const BackgroundColorGrid({super.key});

  @override
  State<BackgroundColorGrid> createState() => _BackgroundColorGridState();
}

final home = Platform.environment['HOME'];
final List<String> filePaths = [
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gtk-4.0/gtk.css',
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gtk-4.0/gtk-dark.css',
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gtk-3.0/gtk.css',
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gtk-3.0/gtk-dark.css',
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gnome-shell/gnome-shell.css',
  '$home/.themes/Everforest-Dark-Soft-Adaptive/gnome-shell/pad-osd.css',
  '$home/.config/gtk-4.0/gtk.css',
  '$home/.config/gtk-4.0/gtk-dark.css',
];

class _BackgroundColorGridState extends State<BackgroundColorGrid> {
  String background = '#000000'; // default color

  @override
  void initState() {
    super.initState();
    init(); // Call init to read background color from GTK theme
  }

  void init() {
    try {
      final file =
          File('${Platform.environment['HOME']}/.config/gtk-4.0/gtk.css');

      final contents = file.readAsStringSync();

      final bgMatch =
          RegExp(r'background-color:\s*(#[A-Fa-f0-9]{6})').firstMatch(contents);

      final hex =
          bgMatch != null ? _parseHexColor(bgMatch.group(1)!) : '#000000';

      setState(() {
        background = hex;
      });

      print('Background color: $background');
    } catch (e) {
      print('Failed to load GTK theme: $e');
    }
  }

  Color? parseColors(String hex) {
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final colorValue = int.tryParse('FF$clean', radix: 16);
      if (colorValue != null) {
        return Color(colorValue);
      }
    }
    return null;
  }

  String _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '').toUpperCase();
    return '#$clean';
  }

  Future<void> applyAndSaveColor(String oldColorHex, String newColorHex) async {
  for (final path in filePaths) {
    final file = File(path);
    if (await file.exists()) {
      String updatedContent = await file.readAsString();
      updatedContent =
          updatedContent.replaceAll(oldColorHex.toUpperCase(), newColorHex.toUpperCase());
      updatedContent =
          updatedContent.replaceAll(oldColorHex.toLowerCase(), newColorHex.toLowerCase());
      updatedContent =
          updatedContent.replaceAll(oldColorHex, newColorHex); // fallback

      await file.writeAsString(updatedContent);
      print('✔ Updated $path');
    } else {
      print('⚠️ File not found: $path');
    }
  }

  // Update state
  setState(() {
    background = newColorHex;
  });
}


  void showColorEditor(
      BuildContext context, Color initialColor, String oldColorHex) {
    HSVColor hsvColor = HSVColor.fromColor(initialColor);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: hsvColor.toColor(),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider("Hue", hsvColor.hue, 360, (value) {
                    setModalState(() => hsvColor = hsvColor.withHue(value));
                  }),
                  _buildSlider("Saturation", hsvColor.saturation, 1, (value) {
                    setModalState(
                        () => hsvColor = hsvColor.withSaturation(value));
                  }),
                  _buildSlider("Value", hsvColor.value, 1, (value) {
                    setModalState(() => hsvColor = hsvColor.withValue(value));
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final newColorHex =
                          '#${hsvColor.toColor().value.toRadixString(16).substring(2).toUpperCase()}';
                      await applyAndSaveColor(oldColorHex, newColorHex);
                      // for (final path in filePaths) {
                      //   final file = File(path);
                      //   if (await file.exists()) {
                      //     // Escape '#' in color values
                      //     final escapedOldHex =
                      //         oldColorHex.replaceAll('#', '\\#');
                      //     final escapedNewHex =
                      //         newColorHex.replaceAll('#', '\\#');

                      //     // Running the `awk` command
                      //     final result = await Process.run(
                      //       'awk',
                      //       [
                      //         '-v',
                      //         'old=$escapedOldHex',
                      //         '-v',
                      //         'new=$escapedNewHex',
                      //         '{ gsub(old, new); print }',
                      //         path,
                      //       ],
                      //     );

                      //     // Check if there were any errors
                      //     if (result.exitCode == 0) {
                      //       print(
                      //           '✅ Replaced $oldColorHex with $newColorHex in $path');
                      //     } else {
                      //       print(
                      //           '⚠️ Error replacing color in $path: ${result.stderr}');
                      //     }
                      //   } else {
                      //     print('⚠️ File not found: $path');
                      //   }
                      // }

                      // for (final path in filePaths) {
                      //   final file = File(path);
                      //   if (file.existsSync()) {
                      //     final escapedOldHex =
                      //         oldColorHex.replaceAll('#', '\\\\#');
                      //     await Process.run('bash', [
                      //       '-c',
                      //       "awk '{gsub(/$escapedOldHex/, \"$newColorHex\"); print}' \"$path\" > \"$path.tmp\" && mv \"$path.tmp\" \"$path\""
                      //     ]);
                      //     print('✔ Updated $path');
                      //   }
                      // }

                      // applyAndSaveColor(oldColorHex, newColorHex);

                      // Run GNOME Shell theme temporary reset
                      await Process.run('bash', [
                        '-c',
                        "t=\$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d \"'\"); "
                            "gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'; "
                            "gsettings set org.gnome.shell.extensions.user-theme name \"\$t\""
                      ]);

                      // // Run GTK theme temporary reset
                      await Process.run('bash', [
                        '-c',
                        "t=\$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"'\"); "
                            "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'; "
                            "gsettings set org.gnome.desktop.interface gtk-theme \"\$t\""
                      ]);

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
                        'GTK Background color refreshed!'
                      ]);
                      Navigator.pop(context);
                    },
                    child: const Text("Apply & Save"),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: value, max: max, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = parseColors(background);

    return GridView.builder(
      itemCount: 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (color != null) {
              showColorEditor(context, color, background);
            } else {
              print("Invalid color: $background");
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                background,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
