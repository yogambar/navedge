import 'package:flutter/material.dart';
import '../screens/about_screen.dart';

class AboutButton extends StatelessWidget {
  final double? iconSize;
  final VoidCallback? onPressed;

  const AboutButton({super.key, this.iconSize, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutScreen()),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth * 0.6; // Adjust factor as needed
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconSize ?? size + 10, // Add padding
                height: iconSize ?? size + 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/icons/about.jpeg',
                      width: iconSize ?? size,
                      height: iconSize ?? size,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.info_outline,
                          size: iconSize ?? size,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'About',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
