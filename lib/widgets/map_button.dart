import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/map_screen.dart'; // Assuming MapScreen.dart is in the 'screens' directory

/// MapButton is a custom button widget used to represent the map functionality.
/// It displays a traffic layer image as an icon and navigates to the MapScreen when pressed.
class MapButton extends StatelessWidget {
  final double iconSize;
  final Map<LatLng, Map<LatLng, double>>? initialGraph; // Use the parameter name from MapScreen

  const MapButton({
    Key? key,
    this.iconSize = 60.0,
    this.initialGraph, // Make it optional to match MapScreen's constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(initialGraph: initialGraph), // Pass initialGraph
          ),
        );
      },
      child: Tooltip(
        message: "Open Map",
        child: SizedBox(
          width: iconSize + 10,
          height: iconSize + 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/maps/traffic_layer.png',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.map_outlined,
                    size: iconSize,
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
