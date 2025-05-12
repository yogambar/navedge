import '../constants/api_constants.dart';

class StreetViewService {
  String getStreetViewUrl({
    required double latitude,
    required double longitude,
    int? sizeX = 600,
    int? sizeY = 300,
    num? heading = 0,
    num? pitch = 0,
    int? fov = 90,
  }) {
    try {
      final url = ApiConstants.streetViewStaticUrl(
        latitude: latitude,
        longitude: longitude,
        sizeX: sizeX,
        sizeY: sizeY,
        heading: heading,
        pitch: pitch,
        fov: fov,
      ).toString();
      print('StreetViewService: Generated Street View URL (direct): $url');
      return url;
    } catch (e) {
      print('StreetViewService: Error generating Street View URL (direct): $e');
      return ''; // Or handle the error as needed
    }
  }

  String getProxyStreetViewUrl({
    required double latitude,
    required double longitude,
    int? sizeX = 600,
    int? sizeY = 300,
    num? heading = 0,
    num? pitch = 0,
    int? fov = 90,
  }) {
    try {
      final url = ApiConstants.proxyStreetViewStaticUrl(
        latitude: latitude,
        longitude: longitude,
        sizeX: sizeX,
        sizeY: sizeY,
        heading: heading,
        pitch: pitch,
        fov: fov,
      ).toString();
      print('StreetViewService: Generated Street View URL (proxy): $url');
      return url;
    } catch (e) {
      print('StreetViewService: Error generating Street View URL (proxy): $e');
      return ''; // Or handle the error as needed
    }
  }
}
