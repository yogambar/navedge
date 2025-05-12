import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteModel {
  final List<PointLatLng> polylinePoints;
  final int distanceMeters;
  final String duration; // Can be a string like "1 hour 30 mins"

  RouteModel({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.duration,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final List<PointLatLng> points = PolylinePoints()
        .decodePolyline(json['overview_polyline']['points'] as String)
        .cast<PointLatLng>();

    final legs = json['legs'] as List<dynamic>;
    int totalDistance = 0;
    String totalDuration = '';

    if (legs.isNotEmpty) {
      totalDistance = (legs.first['distance']['value'] as int?) ?? 0;
      totalDuration = (legs.first['duration']['text'] as String?) ?? '';
      // If there are multiple legs, you might want to sum the distance and duration
      for (var i = 1; i < legs.length; i++) {
        totalDistance += (legs[i]['distance']['value'] as int?) ?? 0;
        // For duration, you might need a more sophisticated way to combine them
        // For simplicity, we'll just take the first leg's duration for now.
        // A better approach might involve summing the 'value' in seconds and then formatting.
      }
    }

    return RouteModel(
      polylinePoints: points,
      distanceMeters: totalDistance,
      duration: totalDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polylinePoints': polylinePoints.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
      'distanceMeters': distanceMeters,
      'duration': duration,
    };
  }
}
