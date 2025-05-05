import 'package:flutter/material.dart';

class RouteInfoWidget extends StatelessWidget {
  final double distanceKm;
  final String duration;

  const RouteInfoWidget({
    Key? key,
    required this.distanceKm,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, color: Colors.blue),
              const SizedBox(height: 4),
              Text(
                'Distance',
                style: Theme.of(context).textTheme.bodySmall, // More likely replacement for caption
              ),
              Text(
                '${distanceKm.toStringAsFixed(2)} km',
                style: Theme.of(context).textTheme.titleMedium?.copyWith( // Keeping titleMedium
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, color: Colors.grey),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, color: Colors.orange),
              const SizedBox(height: 4),
              Text(
                'Estimated Time',
                style: Theme.of(context).textTheme.bodySmall, // More likely replacement for caption
              ),
              Text(
                duration,
                style: Theme.of(context).textTheme.titleMedium?.copyWith( // Keeping titleMedium
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
