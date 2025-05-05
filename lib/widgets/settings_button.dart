import 'package:flutter/material.dart';
import '../screens/settings_screen.dart'; // Import the SettingsScreen

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional custom callback for button press
  final double iconSize; // Customizable size for the icon
  final String iconPath; // Path to the settings icon asset

  const SettingsButton({
    super.key,
    this.onPressed,
    this.iconPath = 'assets/images/icons/settings.png', // Default settings icon path
    this.iconSize = 60.0, // Default icon size matching HelpButton
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        // Default navigation to SettingsScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
      child: Tooltip(
        message: 'Open Settings', // Tooltip for improved accessibility
        child: SizedBox(
          width: iconSize + 10, // Add padding like HelpButton
          height: iconSize + 10, // Add padding like HelpButton
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueAccent, // Same background color as HelpButton
              borderRadius: BorderRadius.circular(12.0), // Same rounded corners as HelpButton
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Same padding as HelpButton
              child: Image.asset(
                iconPath,
                width: iconSize, // Set width to match HelpButton's icon size
                height: iconSize, // Set height to match HelpButton's icon size
                fit: BoxFit.contain, // Ensures the image fits properly
                errorBuilder: (context, error, stackTrace) {
                  // Provides fallback to default icon in case of asset loading failure
                  return Icon(Icons.settings, color: Colors.white, size: iconSize); // Match icon color and size
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
