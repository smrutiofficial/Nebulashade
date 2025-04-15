import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool installedThemes = false;
  bool installedIcons = false;
  bool installedExtensions = false;
  bool atPlusThemes = false;
  bool wallpaperAlbum = false;

  bool autoRun = false;
  bool backgroundUpdate = false;
  bool smallerConfigs = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 50),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "config.zip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "last updated : never",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighten(AppColors.background, 0.0),
                  foregroundColor: AppColors.buttonText,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text("Refresh Loc."),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighten(AppColors.background, 0.0),
                  foregroundColor: AppColors.buttonText,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text("Apply Config"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Backup Data",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Select which of the following you want to backup",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(5, (index) {
              final titles = [
                "Installed Themes",
                "Installed Icons",
                "Installed Extensions",
                "AT+ Themes",
                "Wallpaper Album",
              ];

              final values = [
                installedThemes,
                installedIcons,
                installedExtensions,
                atPlusThemes,
                wallpaperAlbum,
              ];

              return Padding(
                padding: EdgeInsets.only(bottom: index == 4 ? 0 : 1),
                child: _buildToggleTile(
                  titles[index],
                  values[index],
                  (val) {
                    setState(() {
                      if (index == 0) installedThemes = val;
                      if (index == 1) installedIcons = val;
                      if (index == 2) installedExtensions = val;
                      if (index == 3) atPlusThemes = val;
                      if (index == 4) wallpaperAlbum = val;
                    });
                  },
                  isFirst: index == 0,
                  isLast: index == 4,
                ),
              );
            }),
          ),

          const SizedBox(height: 30),
          const Text(
            "More options",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Some more available options",
            style: TextStyle(
              color: Color.fromARGB(255, 136, 139, 145),
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),

          // ✨ Updated section with proper gap between each tile
          ...List.generate(4, (index) {
            final titles = [
              "Update Location : null",
              "Auto-Run Backup",
              "Background update",
              "Smaller configs (better for sharing)",
            ];

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == 3 ? 0 : 1), // thin divider spacing
              child: _buildOptionTile(
                titles[index],
                hasArrow: index == 0,
                toggle: index == 0
                    ? null
                    : [autoRun, backgroundUpdate, smallerConfigs][index - 1],
                onToggle: index == 0
                    ? null
                    : (val) {
                        setState(() {
                          if (index == 1) autoRun = val;
                          if (index == 2) backgroundUpdate = val;
                          if (index == 3) smallerConfigs = val;
                        });
                      },
                isFirst: index == 0,
                isLast: index == 3,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    bool value,
    Function(bool) onChanged, {
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lighten(AppColors.background, 0.0),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor:
                  Color(0xFF151c26), // Color of the switch thumb when ON
              activeTrackColor: Color(0xFFbdcadb), // Background color when ON
              inactiveThumbColor:
                  Color(0xFFbdcadb), // Color of the switch thumb when OFF
              inactiveTrackColor:
                  Color(0xFF151c26), // Background color when OFF
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    String title, {
    bool hasArrow = false,
    bool? toggle,
    Function(bool)? onToggle,
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lighten(AppColors.background, 0.0),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (hasArrow)
            const Icon(Icons.chevron_right, color: Colors.white30)
          else if (toggle != null && onToggle != null)
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: toggle,
                onChanged: onToggle,
                activeColor:
                    Color(0xFF151c26), // Color of the switch thumb when ON
                activeTrackColor: Color(0xFFbdcadb), // Background color when ON
                inactiveThumbColor:
                    Color(0xFFbdcadb), // Color of the switch thumb when OFF
                inactiveTrackColor:
                    Color(0xFF151c26), // Background color when OFF
              ),
            ),
        ],
      ),
    );
  }
}
