import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorPaletteScreen extends StatefulWidget {
  final ImageProvider imageProvider;

  const ColorPaletteScreen({super.key, required this.imageProvider});

  @override
  _ColorPaletteScreenState createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends State<ColorPaletteScreen> {
  PaletteGenerator? _palette;
  String? _selectedPaletteLabel; // Track selected color palette by label

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    final palette = await PaletteGenerator.fromImageProvider(
      widget.imageProvider,
      size: const Size(200, 200),
      maximumColorCount: 32,
    );

    setState(() {
      _palette = palette;
    });
  }

  List<Color> generateShadesBoth(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);

    // Slightly darker starting tone: range from 0.12 to 0.8
    return List.generate(7, (index) {
      final step = index / 6; // 0 to 1
      final lightness = 0.12 + (0.68 * step); // starts at 0.12, ends at 0.8
      return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    });
  }

  Widget _buildColorPalette(String label, Color? baseColor) {
    final shades = generateShadesBoth(baseColor ?? Colors.transparent);
    final isSelected = _selectedPaletteLabel == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaletteLabel = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.white12 : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final boxCount = shades.length;
                final availableWidth = constraints.maxWidth;
                final boxWidth = availableWidth / boxCount;

                return Row(
                  children: List.generate(boxCount, (index) {
                    return Container(
                      width: boxWidth,
                      height: 32,
                      decoration: BoxDecoration(
                        color: shades[index],
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0
                              ? const Radius.circular(6)
                              : Radius.zero,
                          bottomLeft: index == 0
                              ? const Radius.circular(6)
                              : Radius.zero,
                          topRight: index == boxCount - 1
                              ? const Radius.circular(6)
                              : Radius.zero,
                          bottomRight: index == boxCount - 1
                              ? const Radius.circular(6)
                              : Radius.zero,
                        ),
                      ),
                    );
                  }),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image(image: widget.imageProvider, fit: BoxFit.cover);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: Colors.white,
        title: const Text(
          "Color Palette",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _palette == null
          ? const Center(child: CircularProgressIndicator())
          : Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageWidget,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildColorPalette(
                            "Dominant Color", _palette!.dominantColor?.color),
                        _buildColorPalette(
                            "Vibrant Color", _palette!.vibrantColor?.color),
                        _buildColorPalette("Dark Vibrant Color",
                            _palette!.darkVibrantColor?.color),
                        _buildColorPalette("Light Vibrant Color",
                            _palette!.lightVibrantColor?.color),
                        _buildColorPalette(
                            "Muted Color", _palette!.mutedColor?.color),
                        _buildColorPalette("Dark Muted Color",
                            _palette!.darkMutedColor?.color),
                        _buildColorPalette("Light Muted Color",
                            _palette!.lightMutedColor?.color),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
