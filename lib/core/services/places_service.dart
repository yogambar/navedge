import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/place_model_map.dart';
import '../models/prediction_model.dart';

class PlacesService {
  final bool _useDirectApi = true; // Consider making this configurable

  Future<List<Prediction>> getPlacePredictions(String input) async {
    print('PlacesService: getPlacePredictions called with input: $input');
    if (_useDirectApi) {
      return _fetchPlacePredictionsViaApi(input);
    } else {
      return _fetchPlacePredictionsViaProxy(input);
    }
  }

  Future<List<Prediction>> _fetchPlacePredictionsViaApi(String input) async {
    final url = ApiConstants.placesAutocompleteUrl(input);
    print('PlacesService: Fetching predictions via API from URL: $url');
    try {
      final response = await http.get(url);
      print('PlacesService: API response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('PlacesService: API response body: $data');
        if (data['predictions'] != null) {
          final predictions = (data['predictions'] as List)
              .map((json) => Prediction.fromJson(json))
              .toList();
          print('PlacesService: Parsed predictions: $predictions');
          return predictions;
        } else {
          print('PlacesService: API response has no predictions.');
          return [];
        }
      } else {
        print('Places Autocomplete API failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Places Autocomplete API error: $e');
      return [];
    }
  }

  Future<List<Prediction>> _fetchPlacePredictionsViaProxy(String input) async {
    final url = ApiConstants.proxyPlacesAutocompleteUrl(input);
    print('PlacesService: Fetching predictions via proxy from URL: $url');
    try {
      final response = await http.get(url);
      print('PlacesService: Proxy response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('PlacesService: Proxy response body: $data');
        if (data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((json) => Prediction.fromJson(json))
              .toList();
        } else {
          print('PlacesService: Proxy response has no predictions.');
          return [];
        }
      } else {
        print('Places Autocomplete via proxy failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Places Autocomplete via proxy error: $e');
      return [];
    }
  }
}
