import 'package:flutter/material.dart';
import '../screens/login_screen.dart'; // Import the LoginScreen

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional custom callback for button press
  final double iconSize; // Adjustable icon size

  const LoginButton({
    super.key,
    this.onPressed,
    this.iconSize = 60.0, // Match HelpButton's default iconSize
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        // Default navigation to LoginScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Tooltip(
        message: 'Login', // Tooltip for accessibility
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
              child: Icon(
                Icons.login,
                size: iconSize,
                color: Colors.white, // Match HelpButton's icon color
              ),
            ),
          ),
        ),
      ),
    );
  }
}
