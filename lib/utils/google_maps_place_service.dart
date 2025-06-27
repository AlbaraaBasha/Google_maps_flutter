import 'dart:convert';

import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/utils/Api_Keys.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPlaceService {
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
  }) async {
    String baseUrl = 'https://maps.googleapis.com/maps/api/place';
    var response = await http.get(
      Uri.parse(
        '$baseUrl/autocomplete/json?input=$input&key=${ApiKeys.placesApiKey}',
      ),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      return places;
    } else {
      throw Exception('Failed to load predictions');
    }
  }
}
