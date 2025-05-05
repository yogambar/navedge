import 'package:flutter/material.dart';
import 'street_view_dialog.dart'; 

class StreetViewButton extends StatelessWidget {
  final double latitude;
  final double longitude;

  const StreetViewButton({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  void _openStreetView(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StreetViewDialog(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'streetViewButton',
      onPressed: () => _openStreetView(context),
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.streetview),
      tooltip: 'Open Street View',
    );
  }
}

