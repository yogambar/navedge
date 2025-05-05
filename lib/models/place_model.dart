part of '../screens/route_planner_screen.dart';

class Prediction {
  final String? description;
  final String? placeId;
  final StructuredFormatting? structuredFormatting;

  Prediction({this.description, this.placeId, this.structuredFormatting});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
      structuredFormatting: json['structured_formatting'] != null
          ? StructuredFormatting.fromJson(json['structured_formatting'])
          : null,
    );
  }
}

class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      secondaryText: json['secondary_text'],
    );
  }
}

class PlaceDetails {
  final String? name;
  final String? formattedAddress;
  final double? rating;
  final String? formattedPhoneNumber;
  final String? website;
  final Geometry? geometry;

  PlaceDetails({
    this.name,
    this.formattedAddress,
    this.rating,
    this.formattedPhoneNumber,
    this.website,
    this.geometry,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      name: json['name'],
      formattedAddress: json['formatted_address'],
      rating: json['rating']?.toDouble(),
      formattedPhoneNumber: json['formatted_phone_number'],
      website: json['website'],
      geometry: json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
    );
  }
}

class Geometry {
  final Location? location;
  final Viewport? viewport;

  Geometry({this.location, this.viewport});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      viewport:
          json['viewport'] != null ? Viewport.fromJson(json['viewport']) : null,
    );
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Viewport {
  final maps.LatLng? northeast;
  final maps.LatLng? southwest;

  Viewport({this.northeast, this.southwest});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      northeast: json['northeast'] != null
          ? maps.LatLng(json['northeast']['lat'], json['northeast']['lng'])
          : null,
      southwest: json['southwest'] != null
          ? maps.LatLng(json['southwest']['lat'], json['southwest']['lng'])
          : null,
    );
  }
}

class Place {
  final Geometry geometry;
  final String name;
  final String? vicinity;
  final String? placeId;
  final double? rating;
  final int? userRatingsTotal;

  Place({
    required this.geometry,
    required this.name,
    this.vicinity,
    this.placeId,
    this.rating,
    this.userRatingsTotal,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      geometry: Geometry.fromJson(json['geometry']),
      name: json['name'],
      vicinity: json['vicinity'],
      placeId: json['place_id'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
    );
  }
}
