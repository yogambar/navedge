import 'package:flutter/material.dart';
import '../screens/all_buttons_screen.dart'; // Import the AllButtonsScreen

/// A button widget to navigate to the All Buttons Screen.
class AllButtonsButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional callback for custom action
  final String iconPath; // Path for the custom icon
  final double iconSize; // Customizable icon size

  const AllButtonsButton({
    Key? key,
    this.onPressed,
    this.iconPath = 'assets/images/icons/home.png', // Default icon path
    this.iconSize = 60.0, // Default icon size matching HelpButton
  }) : super(key: key);

  void _openAllButtonsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllButtonsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => _openAllButtonsScreen(context), // Default action
      child: Tooltip(
        message: 'Go to All Buttons Screen', // Tooltip for accessibility
        child: SizedBox(
          width: iconSize + 10, // Add padding like HelpButton
          height: iconSize + 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueAccent, // Same background color
              borderRadius: BorderRadius.circular(12.0), // Same rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Same padding
              child: Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain, // Ensures the icon is well-contained
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to default icon if the asset fails to load
                  return Icon(Icons.home, size: iconSize, color: Colors.white);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
