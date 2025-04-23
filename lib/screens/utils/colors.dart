import 'package:flutter/material.dart';

String getSelectedBaseColorHex({
  required List<Color> dominantColors,
  required String? selectedLabel,
  required int shadeIndex,
  required List<Color> Function(Color) getFilteredShades,
  required Color fallbackColor,
}) {
  final labels = [
    "Default Color",
    "Dominant Color",
    "Vibrant Color",
    "Dark Vibrant Color",
    "Light Vibrant Color",
    "Muted Color",
    "Dark Muted Color",
    "Light Muted Color"
  ];

  final index = labels.indexOf(selectedLabel ?? "Dominant Color");

  Color baseColor;

  if (index >= 0 && index < dominantColors.length) {
    baseColor = dominantColors[index];
    final shades = getFilteredShades(baseColor);
    baseColor = (shadeIndex >= 0 && shadeIndex < shades.length)
        ? shades[shadeIndex]
        : baseColor;
  } else {
    baseColor = fallbackColor;
  }

  final rgb = baseColor.value & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
