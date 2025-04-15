import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';
import 'package:nebulashade/screens/background_edit_color.dart';
import 'package:nebulashade/screens/folder_edit_color.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CssColorListScreen(extractedColors: []),
  ));
}

class CssColorListScreen extends StatefulWidget {
  final List<Color> extractedColors;
  const CssColorListScreen({super.key, required this.extractedColors});

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

    final regex = RegExp(
      r'#(?:[0-9a-fA-F]{3}){1,2}' // hex
      r'|rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*(?:\d*\.\d+|\d+))?\s*\)', // rgb/rgba
      caseSensitive: false,
    );

    final matches = <String>{};
    for (var content in fileContents) {
      matches.addAll(regex.allMatches(content).map((m) => m.group(0)!));
    }

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

    bool _invertSwitch = true;
    int selectedPaletteColorIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lighten(AppColors.background, 0.04),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void handleInvertToggle(bool value) {
            setState(() {
              _invertSwitch = value;
              modifiedColorCodes =
                  modifiedColorCodes.map((c) => invertColor(c)).toList();
            });
          }

          void handleDynamicAdapt() {
            if (widget.extractedColors.isEmpty || selectedIndexes.isEmpty)
              return;

            // 🟢 Always use original base colors for average hue
            double averageHue = selectedIndexes
                    .map((i) =>
                        HSVColor.fromColor(parseColor(colorCodes[i])!).hue)
                    .reduce((a, b) => a + b) /
                selectedIndexes.length;

            // 🟢 Target hue from the selected palette color
            final targetHue = HSVColor.fromColor(
              widget.extractedColors[selectedPaletteColorIndex],
            ).hue;

            double delta = (targetHue - averageHue) % 360;
            if (delta < 0) delta += 360;

            setModalState(() {
              hueShift = delta;
            });

            setState(() {
              for (var i in selectedIndexes) {
                modifiedColorCodes[i] = shiftHuePreservingFormat(
                    colorCodes[i], delta); // 🔁 base colors
              }
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.extractedColors.length,
                    itemBuilder: (context, index) {
                      final color = widget.extractedColors[index];
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedPaletteColorIndex = index;
                          });
                        },
                        child: Container(
                          // margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 67,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            // shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedPaletteColorIndex == index
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Invert Colors",
                      style: TextStyle(color: AppColors.accent),
                    ),
                    Switch(
                      value: _invertSwitch,
                      onChanged: (value) {
                        setModalState(() => _invertSwitch = value);
                        handleInvertToggle(value);
                      },
                      activeColor: Color(0xFF151c26),
                      activeTrackColor: Color(0xFFbdcadb),
                      inactiveThumbColor: Color(0xFFbdcadb),
                      inactiveTrackColor: Color(0xFF151c26),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Adjust Hue",
                  style: TextStyle(
                      color: AppColors.buttonText, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: hueShift,
                  min: 0,
                  max: 360,
                  onChanged: (value) {
                    setModalState(() => hueShift = value);
                    setState(() {
                      for (var i in selectedIndexes) {
                        modifiedColorCodes[i] =
                            shiftHuePreservingFormat(colorCodes[i], value);
                      }
                    });
                  },
                ),
                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      onPressed: handleDynamicAdapt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lighten(
                            AppColors.background, 0.1), // Customize as needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              6), // Adjust the radius here
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20), // Optional: more padding
                        // Optional: adjust elevation
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Dynamic Adapt",
                            style: const TextStyle(
                              color: AppColors.buttonText,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.bolt,
                            color: AppColors.subtext,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lighten(
                        AppColors.background, 0.1), // Customize as needed
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(6), // Adjust the radius here
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20), // Optional: more padding
                    // Optional: adjust elevation
                  ),
                  child: const Text(
                    "Apply and Save",
                    style: TextStyle(
                      color: AppColors.buttonText, // Custom text color
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String invertColor(String colorCode) {
    final color = parseColor(colorCode);
    if (color == null) return colorCode;

    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;
    final a = color.alpha;

    if (colorCode.startsWith('#')) {
      return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    } else if (colorCode.startsWith('rgba')) {
      return 'rgba($r, $g, $b, ${(a / 255).toStringAsFixed(2)})';
    } else if (colorCode.startsWith('rgb')) {
      return 'rgb($r, $g, $b)';
    }
    return colorCode;
  }

  int screen = 0; // define at the top of your State class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.background,
      ),
      body: modifiedColorCodes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            screen = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighten(
                              AppColors.background, 0.2), // 👈 background color
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: screen == 0
                                  ? AppColors.lighten(AppColors.background, 0.6)
                                  : Colors.transparent, // 👈 border color
                              width: screen == 0 ? 1.5 : 0, // 👈 border width
                            ),
                            borderRadius:
                                BorderRadius.circular(6), // 👈 border radius
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          child: Text(
                            "System",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            screen = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighten(
                              AppColors.background, 0.2), // 👈 background color
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: screen == 1
                                  ? AppColors.lighten(AppColors.background, 0.6)
                                  : Colors.transparent, // 👈 border color
                              width: screen == 1 ? 1.5 : 0, // 👈 border width
                            ),
                            borderRadius:
                                BorderRadius.circular(6), // 👈 border radius
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          child: Text(
                            "Background",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            screen = 2;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighten(
                              AppColors.background, 0.2), // 👈 background color
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: screen == 2
                                  ? AppColors.lighten(AppColors.background, 0.6)
                                  : Colors.transparent, // 👈 border color
                              width: screen == 2 ? 1.5 : 0, // 👈 border width
                            ),
                            borderRadius:
                                BorderRadius.circular(6), // 👈 border radius
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          child: Text(
                            "Folder",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  // ------------------------------
                  screen == 0
                      ? Expanded(
                          child: GridView.builder(
                            itemCount: modifiedColorCodes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.5,
                            ),
                            itemBuilder: (context, index) {
                              final color =
                                  parseColor(modifiedColorCodes[index]);
                              return GestureDetector(
                                onTap: () => onColorTap(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color ?? Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : screen == 1
                          // background screen
                          ? Expanded(
                              child: BackgroundColorGrid(
                                // colorCode: modifiedColorCodes.isNotEmpty
                                //     ? modifiedColorCodes[0]
                                //     : '#FFFFFF', // Pass the first color from the list (or default to white)
                              ),
                            )
                          : Center(
                              child: Text("Folder screen"),
                            )
                ],
              ),
            ),
    );
  }
}
