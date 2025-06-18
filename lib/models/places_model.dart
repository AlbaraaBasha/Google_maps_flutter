import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesModel {
  final String id;
  final LatLng latLng;
  final String name;

  PlacesModel({required this.id, required this.latLng, required this.name});
}

List<PlacesModel> places = [
  PlacesModel(
    id: '1',
    latLng: LatLng(37.7749, -122.4194), // San Francisco coordinates
    name: 'San Francisco',
  ),
  PlacesModel(
    id: '2',
    latLng: LatLng(34.0522, -118.2437), // Los Angeles coordinates
    name: 'Los Angeles',
  ),
  PlacesModel(
    id: '3',
    latLng: LatLng(40.7128, -74.0060), // New York City coordinates
    name: 'New York City',
  ),
];
