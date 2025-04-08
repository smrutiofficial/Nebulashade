import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Preview + Album Selection)
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
                        // Workspace Indicator
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

                        // Image Preview
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/test.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Right: Album Selection & Adaptive Colours
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Album Selection Box
                      Container(
                        padding: EdgeInsets.all(12),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.cardBackground,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Album Label + Icons
                            Row(
                              children: [
                                Text("Album",
                                    style: TextStyle(
                                        color: AppColors.subtext, fontSize: 14)),
                                SizedBox(width: 18),
                                Icon(Icons.edit,
                                    color: AppColors.subtext, size: 14),
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
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.buttonBackground,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 24, horizontal: 25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text("Choose an Album",
                                          style: TextStyle(
                                              color: AppColors.subtext)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Adaptive Colours Section
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text("Adaptive Colours",
                                style: TextStyle(
                                    color: AppColors.subtext, fontSize: 14)),
                            Spacer(),
                            Icon(Icons.auto_awesome, color: AppColors.subtext),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),

            // Theme Settings List
            _buildThemeOption(
                "Global Theme", "Everforest-Dark-Soft-Adaptive", Icons.add),
            _buildThemeOption(
                "GTK 3.0 Theme", "Everforest-Dark-Soft-Adaptive", Icons.edit),
            _buildThemeOption(
                "GTK 4.0 Theme", "Everforest-Dark-Soft-Adaptive", Icons.edit),
            _buildThemeOption(
                "Gnome Shell", "Everforest-Dark-Soft", Icons.edit),

            SizedBox(height: 16),

            // Toggle Dark Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Toggle Dark Mode",
                    style: TextStyle(color: AppColors.subtext, fontSize: 14)),
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

            // Open CSS Button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2a384c),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: Text("Open CSS file",
                    style: TextStyle(color: AppColors.subtext)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to Build Theme Options
  Widget _buildThemeOption(String title, String themeName, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(color: AppColors.subtext, fontSize: 14)),
          if (title == "Global Theme") ...[
            SizedBox(width: 8),
            Icon(Icons.info, color: Colors.white70, size: 24),
          ],
          Spacer(),
          Container(
            width: 450,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(themeName,
                style: TextStyle(color: AppColors.textprimary)),
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
