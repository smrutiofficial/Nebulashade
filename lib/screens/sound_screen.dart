import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({Key? key}) : super(key: key);

  @override
  _SoundScreenState createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  List<String> soundThemes = [];
  String? selectedTheme;
  bool isLoading = true;

  Future<List<String>> fetchSoundThemes() async {
    // final home = Platform.environment['HOME'];
    // final dir = Directory('$home/.local/share/sounds');
    final dir = Directory('/usr/share/sounds');

    if (await dir.exists()) {
      final List<String> themes = [];

      await for (var entity in dir.list()) {
        if (entity is Directory) {
          final name = entity.path.split('/').last;
          if (name.trim().isNotEmpty) {
            themes.add(name);
          }
        }
      }

      return themes;
    }
    return [];
  }

  Future<String?> getCurrentSystemSoundTheme() async {
    try {
      final result = await Process.run(
        'gsettings',
        ['get', 'org.gnome.desktop.sound', 'theme-name'],
      );
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().replaceAll("'", "");
      }
    } catch (e) {
      print("Error fetching current theme: $e");
    }
    return null;
  }

  Future<void> initSoundThemes() async {
    final themes = await fetchSoundThemes();
    final current = await getCurrentSystemSoundTheme();

    setState(() {
      soundThemes = themes;
      selectedTheme = themes.contains(current)
          ? current
          : (themes.isNotEmpty ? themes.first : null);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initSoundThemes();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Loading ...", style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      );
    }

    if (soundThemes.isEmpty) {
      return const Center(
        child: Text(
          "No sound themes found in ~/.local/share/sounds",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // outer Column to push container to top
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.lighten(AppColors.background, 0.0),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    // const Text(
    //   "System Sound Theme",
    //   style: TextStyle(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w400,
    //     color: Colors.white,
    //   ),
    // ),
    // const SizedBox(height: 20),

    // 👇 Wrap Text + Dropdown in a single Row
    Row(
      children: [
        Expanded(
          flex: 9,
          child: const Text(
            "System Sound Theme",
            style: TextStyle(color: Colors.white,fontSize: 14),
          ),
        ),
        const SizedBox(width: 80),
        Expanded( 
          flex: 1,// to prevent overflow and make it responsive
          child: DropdownButtonHideUnderline(
  child: DropdownButton<String>(
    value: selectedTheme,
    isExpanded: true,
    dropdownColor: AppColors.cardBackground,
    iconEnabledColor: Colors.white,
    style: const TextStyle(color: Colors.white),
    items: soundThemes.map((theme) {
      return DropdownMenuItem<String>(
        value: theme,
        child: Text(theme),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedTheme = value;
        Process.run('gsettings', [
          'set',
          'org.gnome.desktop.sound',
          'theme-name',
          value!,
        ]);
      });
    },
  ),
),

        ),
      ],
    ),
  ],
),

          ),
        ],
      ),
    );
  }
}
