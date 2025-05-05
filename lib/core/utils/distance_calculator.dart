import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class DistanceCalculator {
  static double calculateDistance(gmaps.LatLng latLng1, gmaps.LatLng latLng2) {
    const double earthRadiusKm = 6371.0;

    double lat1Rad = _toRadians(latLng1.latitude);
    double lon1Rad = _toRadians(latLng1.longitude);
    double lat2Rad = _toRadians(latLng2.latitude);
    double lon2Rad = _toRadians(latLng2.longitude);

    double deltaLat = lat2Rad - lat1Rad;
    double deltaLon = lon2Rad - lon1Rad;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c; // Distance in kilometers
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
