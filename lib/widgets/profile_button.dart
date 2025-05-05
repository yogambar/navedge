import 'package:flutter/material.dart';
import '../screens/profile_screen.dart'; // Import the ProfileScreen

class ProfileButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional onPressed callback for flexibility
  final double iconSize; // Adjustable size for the icon
  final Color? buttonColor; // Optional button color parameter

  const ProfileButton({
    super.key,
    this.onPressed,
    this.iconSize = 60.0, // Match HelpButton's default iconSize
    this.buttonColor, // Add the optional buttonColor to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        // Default navigation action to ProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      child: Tooltip(
        message: 'Profile', // Tooltip for accessibility
        child: SizedBox(
          width: iconSize + 10, // Add padding like HelpButton
          height: iconSize + 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: buttonColor ?? Colors.blueAccent, // Use provided color or default
              borderRadius: BorderRadius.circular(12.0), // Same rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Same padding
              child: ClipOval(
                child: Image.asset(
                  'assets/images/icons/profile.jpg', // Use the specified asset
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person_outline,
                      size: iconSize,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
