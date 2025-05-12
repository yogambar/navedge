import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// Load Google Maps API key from .env
  static String get mapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}

