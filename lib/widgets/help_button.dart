import 'package:flutter/material.dart';
import '../screens/help_screen.dart'; // Import the HelpScreen

class HelpButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional onPressed callback
  final double iconSize; // Customizable icon size

  const HelpButton({
    super.key,
    this.onPressed,
    this.iconSize = 60.0, // Default icon size (can be customized)
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        // Default action: Navigate to HelpScreen if no onPressed is provided
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpScreen()),
        );
      },
      child: Tooltip(
        message: 'Help', // Tooltip for better accessibility
        child: SizedBox(
          width: iconSize + 10, // Add some padding around the icon
          height: iconSize + 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              // You can customize the background color or shape here
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12.0), // Optional rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding inside the decorated box
              child: Image.asset(
                'assets/images/icons/help.jpeg',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain, // Adjust fit as needed
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if the asset fails to load
                  return Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: iconSize,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
