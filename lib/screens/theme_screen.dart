import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';
import 'package:nebulashade/screens/ColorPaletteScreen.dart';
import 'package:nebulashade/screens/dynamic/getthemes_screen.dart';
import 'package:nebulashade/screens/dynamic/newwallpaper_screen.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
// import 'package:file_picker/file_picker.dart';

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool isDarkMode = true;
  String? wallpaperPath;

  // Theme variables
  String globalTheme = "Loading...";
  String gtk3Theme = "Loading...";
  String gtk4Theme = "Loading...";
  String shellTheme = "Loading...";
  @override
  void initState() {
    super.initState();
    _getCurrentWallpaper();
    _getCurrentThemes();
    Timer.periodic(Duration(seconds: 3), (_) {
    _getCurrentWallpaper(); // Periodically check for updates
  });
  }

  Future<void> _getCurrentWallpaper() async {
    try {
      final result = await Process.run(
        'gsettings',
        ['get', 'org.gnome.desktop.background', 'picture-uri'],
      );

      if (result.exitCode == 0) {
        String output = result.stdout.toString().trim();

        if (output.startsWith("'file://") && output.endsWith("'")) {
          String path = output.substring(8, output.length - 1);

          // Only update if the path has changed
          if (wallpaperPath != path) {
            setState(() {
              wallpaperPath = path;
            });
            print('Wallpaper path updated: $wallpaperPath'); // Debug log
          }
        }
      }
    } catch (e) {
      print("Error fetching wallpaper: $e");
      setState(() {
        wallpaperPath = null; // Optional: Update UI to show error
      });
    }
  }

  Future<void> _getCurrentThemes() async {
    try {
      final gtkResult = await Process.run(
          'gsettings', ['get', 'org.gnome.desktop.interface', 'gtk-theme']);
      final shellResult = await Process.run('gsettings',
          ['get', 'org.gnome.shell.extensions.user-theme', 'name']);

      setState(() {
        globalTheme = _cleanGSettingsValue(gtkResult.stdout.toString());
        gtk3Theme = globalTheme;
        gtk4Theme = globalTheme;
        shellTheme = _cleanGSettingsValue(shellResult.stdout.toString());
      });
    } catch (e) {
      print("Error fetching theme: $e");
      setState(() {
        globalTheme = "Error"; // Optional: Update UI to show error
      });
    }
  }

  String _cleanGSettingsValue(String value) {
    value = value.trim();
    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

// Folder picker functionality (Linux-specific via GTK integration)
  Future<void> _openFolderPicker() async {
    try {
      final result =
          await Process.run('zenity', ['--file-selection', '--directory']);

      if (result.exitCode == 0) {
        String path = result.stdout.toString().trim();
        setState(() {
          wallpaperPath = path;
        });
      } else {
        print("No folder selected");
      }
    } catch (e) {
      print("Error picking folder: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: 250,
                        height: 265,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 10,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: wallpaperPath != null
                                    ? Image.file(
                                        File(wallpaperPath!),
                                        key: ValueKey(
                                            wallpaperPath), // This triggers a re-render
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ),
                            )
                          ],
                        ),
                        
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 28, vertical: 10),
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.cardBackground,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Album",
                                        style: TextStyle(
                                            color: AppColors.subtext,
                                            fontSize: 14)),
                                    SizedBox(width: 10),
                                    _HoverIcon(icon: Icons.edit, size: 18),
                                    SizedBox(width: 10),
                                    _HoverIcon(
                                        icon: Icons.tab_unselected, size: 18),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NewWallpaper(),
                                          ),
                                        ).then((_) {
                                          _getCurrentWallpaper(); // Refresh wallpaper after returning
                                        });
                                      },
                                      child: _HoverIcon(
                                        icon: Icons.install_desktop,
                                        size: 18,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.photo,
                                        color: AppColors.subtext, size: 24),
                                  ],
                                ),
                                Container(
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ImageRowScroller(),
                                      // Center(
                                      //   child: ElevatedButton(
                                      //     style: ElevatedButton.styleFrom(
                                      //       backgroundColor:
                                      //           AppColors.buttonBackground,
                                      //       padding: EdgeInsets.symmetric(
                                      //           vertical: 24, horizontal: 25),
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(6),
                                      //       ),
                                      //     ),
                                      //     onPressed: () {},
                                      //     child: Text("Choose an Album",
                                      //         style: TextStyle(
                                      //             color: AppColors.subtext)),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              if (wallpaperPath != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ColorPaletteScreen(
                                      imageProvider:
                                          FileImage(File(wallpaperPath!)),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Quick Adapt Colours",
                                      style: TextStyle(
                                          color: AppColors.subtext,
                                          fontSize: 14)),
                                  SizedBox(width: 12),
                                  Icon(Icons.bolt, color: AppColors.subtext),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 36),
                _buildThemeOption("Global Theme", globalTheme, Icons.add),
                _buildThemeOption("GTK 3.0 Theme", gtk3Theme, Icons.edit),
                _buildThemeOption("GTK 4.0 Theme", gtk4Theme, Icons.edit),
                _buildThemeOption("Gnome Shell", shellTheme, Icons.edit),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Toggle Dark Mode",
                        style:
                            TextStyle(color: AppColors.subtext, fontSize: 14)),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: isDarkMode,
                        onChanged: (bool value) {
                          setState(() {
                            isDarkMode = value;
                          });
                        },
                        activeColor: Color(0xFF151c26),
                        activeTrackColor: Color(0xFFbdcadb),
                        inactiveThumbColor: Color(0xFFbdcadb),
                        inactiveTrackColor: Color(0xFF151c26),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                // ---------------------------------------------------
                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2a384c),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {},
                      child: Text("Open CSS file",
                          style: TextStyle(color: AppColors.subtext)),
                    ),
                    SizedBox(width: 10),
                    Container(
                      margin: EdgeInsets.only(bottom: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GetThemes(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .buttonBackground, // Set your desired background color
                          foregroundColor: AppColors.buttonText, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(6), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          elevation:
                              0, // optional: remove elevation if you want a flat style
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      margin: const EdgeInsets.only(bottom: 0),
                      child: ElevatedButton(
                        onPressed: _openFolderPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          foregroundColor: AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          child: Icon(
                            Icons.inventory,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, String themeName, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: AppColors.subtext, fontSize: 14)),
          if (title == "Global Theme") ...[
            SizedBox(width: 8),
            Icon(Icons.info, color: AppColors.accent, size: 24),
          ],
          Spacer(),
          Container(
            width: 450,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Text(themeName, style: TextStyle(color: AppColors.textprimary)),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.5, horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.buttonBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(icon, color: AppColors.subtext),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class _HoverIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const _HoverIcon({required this.icon, this.size = 18});

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: AppColors.subtext,
        ),
      ),
    );
  }
}

class ImageRowScroller extends StatefulWidget {
  const ImageRowScroller({super.key});

  @override
  State<ImageRowScroller> createState() => _ImageRowScrollerState();
}

class _ImageRowScrollerState extends State<ImageRowScroller> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final homeDir = Platform.environment['HOME'] ??
        (await getApplicationDocumentsDirectory()).path;
    final targetDir = Directory('$homeDir/nexwallpapers');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final files = targetDir
        .listSync()
        .whereType<File>()
        .where(
            (file) => file.path.endsWith('.jpg') || file.path.endsWith('.png'))
        .toList();

    setState(() {
      imageFiles = files;
    });
  }

  Future<void> setAsWallpaper(String path) async {
    final uri = 'file://${Uri.encodeFull(path)}'; // Ensure proper URI format

    try {
      final result1 = await Process.run('gsettings', [
        'set',
        'org.gnome.desktop.background',
        'picture-uri',
        uri,
      ]);

      final result2 = await Process.run('gsettings', [
        'set',
        'org.gnome.desktop.background',
        'picture-uri-dark',
        uri,
      ]);

      if (result1.exitCode == 0 && result2.exitCode == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper set successfully!')),
        );
      } else {
        throw Exception("gsettings failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = imageFiles;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.isNotEmpty ? images.length : 5,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final imagePath = images.isNotEmpty
              ? images[index].path
              : 'assets/sample$index.jpg';

          return GestureDetector(
            onTap: () {
              if (images.isNotEmpty) {
                setAsWallpaper(imagePath);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: images.isNotEmpty
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
