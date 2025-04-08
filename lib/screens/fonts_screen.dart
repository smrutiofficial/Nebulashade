import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class FontsScreen extends StatefulWidget {
  @override
  State<FontsScreen> createState() => _FontsScreenState();
}

class _FontsScreenState extends State<FontsScreen> {
  String _hinting = 'Slight';
  String _antialiasing = 'Subpixel';
  double _scalingFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: "Preferred Fonts",),
            const SizedBox(height: 16),

            // Font Option Tiles with spacing
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: _buildOptionTile("Interface Text: Ubuntu Sans",
                  hasArrow: true, isFirst: true, isLast: false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: _buildOptionTile("Document Text: Sans",
                  hasArrow: true, isFirst: false, isLast: false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOptionTile("Monospace Text: Ubuntu Sans Mono",
                  hasArrow: true, isFirst: false, isLast: true),
            ),

            const SectionTitle(title: "Rendering"),
            const SizedBox(height: 8),

            const SettingLabel(title: "Hinting"),
            _buildRadioGroup(
              options: ["Full", "Medium", "Slight", "None"],
              groupValue: _hinting,
              onChanged: (val) => setState(() => _hinting = val),
            ),

            const SizedBox(height: 16),
            const SettingLabel(title: "Antialiasing"),
            _buildRadioGroup(
              options: [
                "Subpixel (for LCD screens)",
                "Standard (grayscale)",
                "None"
              ],
              groupValue: _antialiasing,
              onChanged: (val) => setState(() => _antialiasing = val),
            ),

            const SizedBox(height: 24),
            const SectionTitle(title: "Size"),
            const SizedBox(height: 8),

            _buildScalingTile(),
          ],
        ),
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

  Widget _buildRadioGroup({
    required List<String> options,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isFirst = index == 0;
        final isLast = index == options.length - 1;

        return Padding(
          padding: const EdgeInsets.only(
              bottom: 1), // Add gap between each radio item
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
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
                  Text(option,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14)),
                  Radio<String>(
                    value: option,
                    groupValue: groupValue,
                    onChanged: (val) => onChanged(val!),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScalingTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Scaling Factor",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                onPressed: () {
                  setState(() {
                    if (_scalingFactor > 0.5) {
                      _scalingFactor -= 0.1;
                    }
                  });
                },
              ),
              Text(_scalingFactor.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white70, size: 18),
                onPressed: () {
                  setState(() {
                    if (_scalingFactor < 3.0) {
                      _scalingFactor += 0.1;
                    }
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ));
  }
}

class SettingLabel extends StatelessWidget {
  final String title;
  const SettingLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
           style: const TextStyle(
          fontSize: 12,
          color: AppColors.accent,
          fontWeight: FontWeight.w300,
        ),),
    );
  }
}
