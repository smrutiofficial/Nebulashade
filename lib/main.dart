import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';
// import 'package:nebulashade/screens/background_edit_color.dart';
// import 'package:nebulashade/screens/color_edit_screen.dart';
import 'package:nebulashade/screens/hotkey_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nebulashade/screens/fonts_screen.dart';
import 'package:nebulashade/screens/sound_screen.dart';
// import 'package:nebulashade/screens/window_screen.dart';
// import 'package:nebulashade/screens/extensions_screen.dart' as ext;
import 'package:nebulashade/screens/window_screen.dart' as win;

import 'screens/theme_screen.dart';
import 'screens/icons_screen.dart';
import 'screens/config_screen.dart';
import 'screens/extensions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'components/sidebar_button.dart';

void main() async {
  AppColors.init();
  // BackgroundColorGrid.init(); // ← call it here
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: "NEBULASHADE", // 👈 Set your custom title here
    // size: Size(1343, 750),
    center: true,
    backgroundColor: Colors.transparent,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    MyApp(),
  );
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0; // Track the selected tab index

  final List<Map<String, dynamic>> tabs = [
    {"label": "Theme", "icon": Icons.color_lens, "screen": ThemeScreen()},
    {"label": "Icons", "icon": Icons.insert_emoticon, "screen": IconsScreen()},
    {
      "label": "Config",
      "icon": Icons.settings_applications,
      "screen": ConfigScreen()
    },
    {"label": "Fonts", "icon": Icons.format_size, "screen": FontsScreen()},
    {"label": "Cursors", "icon": Icons.touch_app, "screen": FontsScreen()},
    {"label": "Sound", "icon": Icons.graphic_eq, "screen": SoundScreen()},
    {"label": "Hotkey", "icon": Icons.keyboard, "screen": HotKey()},
    {"label": "Widgets", "icon": Icons.widgets, "screen": HotKey()},
    {"label": "Windows", "icon": Icons.web_asset, "screen": win.WindowScreen()},
    {
      "label": "Extensions",
      "icon": Icons.extension,
      "screen": ExtensionsScreen()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar (List of Tabs)
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  right: BorderSide(
                    color: AppColors.lighten(
                        AppColors.background, 0.0), // Sidebar border color
                    width: 2.0,
                  ),
                ),
              ),
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Push Settings & About to bottom
                children: [
                  // Top Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      tabs.length,
                      (index) => SidebarButton(
                        icon: tabs[index]["icon"], // Pass the icon
                        label: tabs[index]["label"],
                        isSelected: selectedIndex == index,
                        onTap: () {
                          setState(() {
                            selectedIndex = index; // Update selected index
                          });
                        },
                      ),
                    ),
                  ),

                  // Bottom Section: Settings & About
                  Column(
                    children: [
                      SidebarButton(
                        icon: Icons.settings,
                        label: "Settings",
                        isSelected: selectedIndex ==
                            tabs.length, // Unique index for Settings
                        onTap: () {
                          setState(() {
                            selectedIndex =
                                tabs.length; // Select Settings Screen
                          });
                        },
                      ),
                      SidebarButton(
                        icon: Icons.info,
                        label: "About",
                        isSelected: selectedIndex ==
                            tabs.length + 1, // Unique index for About
                        onTap: () {
                          setState(() {
                            selectedIndex =
                                tabs.length + 1; // Select About Screen
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content (Load corresponding screen)
          Expanded(
            flex: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.lighten(AppColors.background, 0.04),
                  borderRadius: BorderRadius.circular(12)),
              child: selectedIndex < tabs.length
                  ? tabs[selectedIndex]["screen"]
                  : (selectedIndex == tabs.length
                      ? SettingsScreen()
                      : AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
