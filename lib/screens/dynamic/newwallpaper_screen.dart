import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class NewWallpaper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.accent,
      ),
      body: Center(child: Text('This is the new page')),
    );
  }
}
