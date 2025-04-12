import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool improveContrast = false;
  bool scaleUp = false;
  bool respectGNOME = false;
  bool toggleAnimations = true;
  bool applyFlatpak = false;
  bool makeShellEditable = false;

  void resetSettings() {
    setState(() {
      improveContrast = false;
      scaleUp = false;
      respectGNOME = false;
      toggleAnimations = true;
      applyFlatpak = false;
      makeShellEditable = false;
    });
  }

  Widget buildSwitch(String label, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white54, fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF151c26),
        activeTrackColor: const Color(0xFFbdcadb),
        inactiveThumbColor: const Color(0xFFbdcadb),
        inactiveTrackColor: const Color(0xFF151c26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "App Settings",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "App specific settings. These do not affect the system.",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  buildSwitch("Improve Contrast", improveContrast, (val) {
                    setState(() => improveContrast = val);
                  }),
                  const Divider(height: 1, color: AppColors.background),
                  buildSwitch("Scale up", scaleUp, (val) {
                    setState(() => scaleUp = val);
                  }),
                  const Divider(height: 1, color: AppColors.background),
                  buildSwitch("Respect GNOME UI", respectGNOME, (val) {
                    setState(() => respectGNOME = val);
                  }),
                  const Divider(height: 1, color: AppColors.background),
                  buildSwitch("Toggle animations", toggleAnimations, (val) {
                    setState(() => toggleAnimations = val);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Theme Settings",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "System level changes. May require admin privileges",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  buildSwitch("Apply Flatpak Theme", applyFlatpak, (val) {
                    setState(() => applyFlatpak = val);
                  }),
                  const Divider(height: 1, color: AppColors.background),
                  buildSwitch(
                      "Make Default Shell Editable", makeShellEditable, (val) {
                    setState(() => makeShellEditable = val);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: resetSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text("Reset Settings"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
