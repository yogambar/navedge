import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; // Import the HomeScreen

class HomeButton extends StatelessWidget {
  final VoidCallback? onPressed; // Optional callback for flexibility
  final double iconSize; // Adjustable size for the icon

  const HomeButton({
    super.key,
    this.onPressed,
    this.iconSize = 84.0, // Default icon size (can be customized)
  });

  void _openHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false, // Clears the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.home, // Standard home icon from MaterialIcons
        size: iconSize,
        color: Colors.blue, // You can customize the color here
      ),
      tooltip: 'Home', // Tooltip for accessibility
      onPressed: onPressed ?? () => _openHomeScreen(context), // Default navigation action
    );
  }
}

