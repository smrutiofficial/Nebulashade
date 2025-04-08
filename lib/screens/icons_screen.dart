import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nebulashade/constants/colours.dart';
import 'package:path/path.dart' as p;

class IconPack {
  final String name;
  final List<String> icons;
  final bool isCorrupt;

  IconPack({required this.name, this.icons = const [], this.isCorrupt = false});
}

class IconsScreen extends StatefulWidget {
  const IconsScreen({Key? key}) : super(key: key);

  @override
  State<IconsScreen> createState() => _IconsScreenState();
}

class _IconsScreenState extends State<IconsScreen> {
  List<IconPack> iconPacks = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    loadIconPacks();
  }

  Future<void> loadIconPacks() async {
    final iconDir =
        Directory('${Platform.environment['HOME']}/.local/share/icons');
    if (!await iconDir.exists()) return;

    final entries = await iconDir.list().toList();
    List<IconPack> loadedPacks = [];

    for (var entity in entries) {
      if (entity is Directory) {
        final name = p.basename(entity.path);
        final themeFile = File(p.join(entity.path, 'index.theme'));

        final scalableDir = Directory(p.join(entity.path, 'apps/scalable'));
        List<FileSystemEntity> iconFiles = [];

        if (await scalableDir.exists()) {
          iconFiles = await scalableDir
              .list()
              .where((f) =>
                  f is File &&
                  (f.path.endsWith('.svg') || f.path.endsWith('.png')))
              .toList();
        }

        if (themeFile.existsSync() || iconFiles.isNotEmpty) {
          loadedPacks.add(
            IconPack(name: name, icons: iconFiles.map((f) => f.path).toList()),
          );
        } else {
          loadedPacks.add(IconPack(name: name, isCorrupt: true));
        }
      }
    }

    setState(() {
      iconPacks = loadedPacks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: iconPacks.asMap().entries.map((entry) {
            final index = entry.key;
            final pack = entry.value;

            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (pack.isCorrupt ? Colors.red : Colors.blueAccent)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Grid or Warning
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: pack.isCorrupt
                          ? const Center(
                              child: Text(
                                'Icon-pack may be Corrupt.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 221, 221, 221),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              physics: const NeverScrollableScrollPhysics(),
                              children: _buildFilteredIcons(pack),
                            ),
                    ),

                    // Icon pack name
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        pack.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredIcons(IconPack pack) {
    final devApps = [
      'file-manager',
      'android-studio',
      'applications-system',
      'audacity',
      'calendar',
      'blender'
    ];

    final iconMap = <String, String>{};

    for (final app in devApps) {
      for (final iconPath in pack.icons) {
        final fileName = p.basenameWithoutExtension(iconPath).toLowerCase();
        if (fileName.contains(app) && !iconMap.containsKey(app)) {
          iconMap[app] = iconPath;
          break;
        }
      }
    }

    return devApps.where((app) => iconMap.containsKey(app)).map((app) {
      final path = iconMap[app]!;
      return Container(
        padding: const EdgeInsets.all(4),
        child: p.extension(path) == '.svg'
            ? SvgPicture.file(
                File(path),
                fit: BoxFit.contain,
                placeholderBuilder: (_) => const Icon(
                  Icons.image,
                  size: 16,
                  color: Colors.white24,
                ),
              )
            : Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 16,
                  color: Colors.white30,
                ),
              ),
      );
    }).toList();
  }
}
