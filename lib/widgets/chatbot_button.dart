import 'package:flutter/material.dart';
import '../screens/chatbot_screen.dart'; // Import the ChatbotScreen

class ChatbotButton extends StatelessWidget {
  final VoidCallback? onPressed; // Custom callback for button press
  final double iconSize; // Dynamic icon size, default set to 60.0

  const ChatbotButton({
    Key? key,
    this.onPressed,
    this.iconSize = 60.0, // Default to 60.0, can be overridden
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        // Default action when onPressed is not provided: Navigate to ChatbotScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );

        // Optionally show feedback when button is pressed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chatbot Opened")),
        );
      },
      child: Tooltip(
        message: 'Chatbot', // Tooltip for accessibility
        child: SizedBox(
          width: iconSize + 10, // Add some padding
          height: iconSize + 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12.0), // Same rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/icons/chatbot.png', // Path to your chatbot icon
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if the asset fails
                  return Icon(
                    Icons.chat_bubble_outline,
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
