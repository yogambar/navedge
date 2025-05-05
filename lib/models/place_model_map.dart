import 'package:google_maps_flutter/google_maps_flutter.dart';

class Prediction {
  final String? description;
  final String? placeId;
  final StructuredFormatting? structuredFormatting;

  Prediction({this.description, this.placeId, this.structuredFormatting});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      structuredFormatting: json['structured_formatting'] == null
          ? null
          : StructuredFormatting.fromJson(
              json['structured_formatting'] as Map<String, dynamic>),
    );
  }
}

class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
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
      name: json['name'] as String?,
      formattedAddress: json['formatted_address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      formattedPhoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
    );
  }
}

class Geometry {
  final Location? location;
  final Viewport? viewport;

  Geometry({this.location, this.viewport});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      viewport: json['viewport'] == null
          ? null
          : Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
    );
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class Viewport {
  final LatLng? northeast;
  final LatLng? southwest;

  Viewport({this.northeast, this.southwest});

  factory Viewport.fromJson(Map<String, dynamic> json) {
    return Viewport(
      northeast: json['northeast'] == null
          ? null
          : LatLng((json['northeast']['lat'] as num?)?.toDouble() ?? 0.0,
              (json['northeast']['lng'] as num?)?.toDouble() ?? 0.0),
      southwest: json['southwest'] == null
          ? null
          : LatLng((json['southwest']['lat'] as num?)?.toDouble() ?? 0.0,
              (json['southwest']['lng'] as num?)?.toDouble() ?? 0.0),
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
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      name: json['name'] as String,
      vicinity: json['vicinity'] as String?,
      placeId: json['place_id'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
    );
  }
}
