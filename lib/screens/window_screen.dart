import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class WindowScreen extends StatefulWidget {
  @override
  State<WindowScreen> createState() => _WindowScreenState();
}

class _WindowScreenState extends State<WindowScreen> {
  bool maximize = true;
  bool minimize = true;
  bool attachDialogs = true;
  bool centerNewWindows = true;
  bool resizeWithRightClick = false;
  bool raiseOnFocus = false;
  String placement = "Right";
  String actionKey = "Super";
  String focusOption = "hover";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle("Titlebar Buttons"),
            _cardList([
              _buildOptionTile("Maximize",
                  toggle: maximize,
                  onToggle: (val) => setState(() => maximize = val),
                  isFirst: true,
                  isLast: false),
              _buildOptionTile("Minimize",
                  toggle: minimize,
                  onToggle: (val) => setState(() => minimize = val),
                  isFirst: false,
                  isLast: false),
              _placementSelector(isFirst: false, isLast: true),
            ]),
            _sectionTitle("Click Actions"),
            _cardList([
              _buildOptionTile("Attach Modal Dialogs",
                  toggle: attachDialogs,
                  onToggle: (val) => setState(() => attachDialogs = val),
                  isFirst: true,
                  isLast: false),
              _buildOptionTile("Center New Windows",
                  toggle: centerNewWindows,
                  onToggle: (val) => setState(() => centerNewWindows = val),
                  isFirst: false,
                  isLast: false),
              _dropdownOptionTile(
                  "Window Action Key",
                  actionKey,
                  ["Super", "Alt", "Meta"],
                  (val) => setState(() => actionKey = val),
                  isFirst: false,
                  isLast: false),
              _buildOptionTile("Resize with Secondary-Click",
                  toggle: resizeWithRightClick,
                  onToggle: (val) => setState(() => resizeWithRightClick = val),
                  isFirst: false,
                  isLast: true),
            ]),
            _sectionTitle("Window Focus"),
            SizedBox(height: 8),
            _focusModeOptions(),
            _cardList([
              _buildOptionTile("Raise Windows When Focused",
                  toggle: raiseOnFocus,
                  onToggle: (val) => setState(() => raiseOnFocus = val),
                  isFirst: true,
                  isLast: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _cardList(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12), // <-- spacing outside
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isEven) {
            return children[index ~/ 2];
          } else {
            return const Divider(
              height: 1,
              color: AppColors.background, // Change this color as needed
              thickness: 1,
            );
// Optional divider between tiles
          }
        }),
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
        color: AppColors.cardBackground,
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
          if (hasArrow)
            const Icon(Icons.chevron_right, color: Colors.white30)
          else if (toggle != null && onToggle != null)
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: toggle,
                onChanged: onToggle,
                activeColor: const Color(0xFF151c26),
                activeTrackColor: const Color(0xFFbdcadb),
                inactiveThumbColor: const Color(0xFFbdcadb),
                inactiveTrackColor: const Color(0xFF151c26),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placementSelector({required bool isFirst, required bool isLast}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Placement",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          Row(
            children: [
              _placementButton("Left"),
              const SizedBox(width: 8),
              _placementButton("Right"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placementButton(String label) {
    final isSelected = placement == label;
    return GestureDetector(
      onTap: () => setState(() => placement = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.buttonBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _dropdownOptionTile(
    String title,
    String selectedValue,
    List<String> options,
    Function(String) onChanged, {
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
          DropdownButton<String>(
            value: selectedValue,
            items: options
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(color: Colors.white70)),
                    ))
                .toList(),
            onChanged: (val) => onChanged(val!),
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackground,
            iconEnabledColor: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _focusModeOptions() {
    final options = {
      "click": {
        "title": "Click to Focus",
        "subtitle": "Windows are focused when they are clicked.",
      },
      "hover": {
        "title": "Focus on Hover",
        "subtitle":
            "Window is focused when hovered with the pointer.\nWindows remain focused when the desktop is hovered.",
      },
      "follows": {
        "title": "Focus Follows Mouse",
        "subtitle":
            "Window is focused when hovered with the pointer. Hovering\nthe desktop removes focus from the previous window.",
      },
    };

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.entries.map((entry) {
          return RadioListTile<String>(
            value: entry.key,
            groupValue: focusOption,
            onChanged: (val) => setState(() => focusOption = val!),
            activeColor: AppColors.accent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.value["title"]!,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value["subtitle"]!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
