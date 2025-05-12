import 'package:flutter/material.dart';

class RoutePlannerButton extends StatelessWidget {
  // Callback function for button press
  final VoidCallback onPressed;
  final double? size; // Optional size parameter

  const RoutePlannerButton({Key? key, required this.onPressed, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = size ?? 60.0; // Use provided size or default to HelpButton's size

    return InkWell(
      onTap: onPressed, // Action triggered when the button is pressed
      child: Tooltip(
        message: 'Route Planner', // Add a tooltip
        child: SizedBox(
          width: effectiveSize + 10, // Match HelpButton's width
          height: effectiveSize + 10, // Match HelpButton's height
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueAccent, // Same background color
              borderRadius: BorderRadius.circular(12.0), // Same rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Same padding
              child: Image.asset(
                'assets/images/icons/gps.png', // Path to the icon image
                fit: BoxFit.contain, // Ensures the image is well-contained
                width: effectiveSize, // Set width
                height: effectiveSize, // Set height
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.map,
                    size: effectiveSize,
                    color: Colors.white,
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
