import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/models/places_details_model/places_details_model.dart';
import 'package:google_maps_section/utils/Api_Keys.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPlaceService {
  String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  Future<List<PlaceAutocompleteModel>> getPredictions({
    required String input,
    required String sessionToken,
  }) async {
    var response = await http.get(
      Uri.parse(
        '$baseUrl/autocomplete/json?input=$input&sessiontoken=$sessionToken&key=${ApiKeys.placesApiKey}',
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

  Future<LatLng> getPlaceDetails({required placeId}) async {
    var response = await http.get(
      Uri.parse(
        '$baseUrl/details/json?place_id=$placeId&key=${ApiKeys.placesApiKey}',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['result'];
      PlacesDetailsModel placeDetails = PlacesDetailsModel.fromJson(data);
      return LatLng(
        placeDetails.geometry!.location!.lat!,
        placeDetails.geometry!.location!.lng!,
      );
    } else {
      throw Exception('Failed to load place details');
    }
  }
}
