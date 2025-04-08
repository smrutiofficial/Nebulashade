import 'package:flutter/material.dart';
import 'package:nebulashade/constants/colours.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark theme background
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Icon
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/nebulashade_icon.png'), // Replace with actual asset
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Title
            Text(
              "NEBULASHADE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 16),

            // Version, Beta, Patreon Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag("vers : 1.0.0"),
                SizedBox(width: 8),
                _buildTag("beta"),
                // SizedBox(width: 8),
                // _buildTag("Patreon", isOutlined: true),
              ],
            ),

            SizedBox(height: 20),

            // Subtitle
            Text(
              "The powerful and modern alternative to Gnome Tweaks",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 250),
              child: Text(
                "I have conducted comprehensive testing using Everforest-GTK on Fedora 39/40 with GNOME 45/46 environment. For any issues encountered, please forward them to nexonix@gmail.com. Kindly include the name of the theme you experienced issues with, along with details of your operating system and GNOME version. If available, please provide log outputs. Running the application from the terminal may also yield additional insights.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(180, 156, 168, 186),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Footer
            Text(
              "Designed by NEXONIX",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for button styling
  Widget _buildTag(String text, {bool isOutlined = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppColors.buttonBackground,
        borderRadius: BorderRadius.circular(8),
        border: isOutlined ? Border.all(color: Colors.white, width: 1.5) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
