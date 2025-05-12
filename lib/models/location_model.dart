import 'package:latlong2/latlong.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address; // Optional: You might want to store the associated address

  LocationModel({required this.latitude, required this.longitude, this.address});

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  factory LocationModel.fromLatLng(LatLng latLng, {String? address}) {
    return LocationModel(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      address: address,
    );
  }

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
}
