import 'dart:convert';

import 'package:google_maps_section/models/location_info_model/location_info_model.dart';
import 'package:google_maps_section/models/routes_model/routes_model.dart';
import 'package:google_maps_section/models/routes_modifiers.dart';
import 'package:google_maps_section/utils/api_keys.dart';
import 'package:http/http.dart' as http;

class RoutesService {
  final String baseUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  Future<RoutesModel> getRoutes({
    required LocationInfoModel origin,
    required LocationInfoModel destination,
    RoutesModifiers? routesModifiers,
  }) async {
    Uri url = Uri.parse(baseUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiKeys.placesApiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };
    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routesModifiers?.toJson() ?? RoutesModifiers().toJson(),
      "languageCode": "en-US",
      "units": "METRIC",
    };
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return RoutesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load routes');
    }
  }
}
