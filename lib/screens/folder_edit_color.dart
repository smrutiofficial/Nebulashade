import 'dart:io';
import 'package:flutter/material.dart';

class FoldercScreen extends StatefulWidget {
  const FoldercScreen({super.key});

  @override
  State<FoldercScreen> createState() => _BackgroundColorGridState();
}

final home = Platform.environment['HOME'];
final List<String> fileNames = [
  'folder-bookmark.svg',
  'folder-code.svg',
  'folder-documents.svg',
  'folder-download.svg',
  'folder-dropbox.svg',
  'folder-games.svg',
  'folder-github.svg',
  'folder-music.svg',
  'folder-open.svg',
  'folder-pictures.svg',
  'folder-projects.svg',
  'folder-publicshare.svg',
  'folder-root.svg',
  'folder-steam.svg',
  'folder.svg',
  'folder-templates.svg',
  'folder-temp.svg',
  'folder-torrent.svg',
  'folder-vbox.svg',
  'folder-video.svg',
  'folder-wine.svg',
  'user-desktop.svg',
  'user-home.svg',
  'folder-music.svg',
];

final List<String> filePaths = fileNames
    .map((name) =>
        '$home/.local/share/icons/Colloid-teal-nord-dark/places/scalable/default-$name')
    .toList();

class _BackgroundColorGridState extends State<FoldercScreen> {
  String background = '#000000'; // default color

  @override
  void initState() {
    super.initState();
    init(); // Call init to read background color from GTK theme
  }

  void init() {
    try {
      final file = File(
        '${Platform.environment['HOME']}/.local/share/icons/Colloid-teal-nord-dark/places/scalable/default-folder.svg',
      );

      final contents = file.readAsStringSync();

      // Extract the original fill color (before replacing it)
      final match = RegExp(r'fill:(#[A-Fa-f0-9]{6})').firstMatch(contents);
      final originalHex = match?.group(1) ?? '#000000';
      print('Original hex color: $originalHex'); // Log the original color

      // Replace only the fill value (not fill-opacity)
      final modified = contents.replaceAllMapped(
        RegExp(r'(id="path2"\s+style="[^"]*?)fill:#[A-Fa-f0-9]{6}'),
        (match) => '${match[1]}fill:#ff0000',
      );
      setState(() {
        background = originalHex; // Use the original hex color
      });
    } catch (e) {
      print('Error reading or parsing SVG: $e');
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
        updatedContent = updatedContent.replaceAll(
            oldColorHex.toUpperCase(), newColorHex.toUpperCase());
        updatedContent = updatedContent.replaceAll(
            oldColorHex.toLowerCase(), newColorHex.toLowerCase());
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

                      await Process.run('bash', [
                        '-c',
                        "t=\$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d \"'\"); "
                            "gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'; "
                            "gsettings set org.gnome.shell.extensions.user-theme name \"\$t\"; "
                            "gnome-shell --replace &"
                      ]);

                      // Run GNOME Shell theme temporary reset
                      // await Process.run('bash', [
                      //   '-c',
                      //   "t=\$(gsettings get org.gnome.shell.extensions.user-theme name | tr -d \"'\"); "
                      //       "gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'; "
                      //       "gsettings set org.gnome.shell.extensions.user-theme name \"\$t\""
                      // ]);
                      // // // Run GTK theme temporary reset
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
