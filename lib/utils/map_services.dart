import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/location_info_model/lat_lng.dart';
import 'package:google_maps_section/models/location_info_model/location.dart';
import 'package:google_maps_section/models/location_info_model/location_info_model.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/models/routes_model/routes_model.dart';
import 'package:google_maps_section/utils/google_maps_place_service.dart';
import 'package:google_maps_section/utils/location_services.dart';
import 'package:google_maps_section/utils/routes_service.dart';

class MapServices {
  LocationServices locationService = LocationServices();
  PlaceService placeService = PlaceService();
  RoutesService routesService = RoutesService();
  LatLng? currentLatLng;
  bool isFirstTime = true;
  getPredictions({
    required TextEditingController searchController,
    required sessionToken,
    required List<PlaceAutocompleteModel> places,
  }) async {
    if (searchController.text.isNotEmpty) {
      var result = await placeService.getPredictions(
        sessionToken: sessionToken,
        input: searchController.text,
      );
      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  void updateCurrentLocation({
    required Set<Marker> markers,
    required GoogleMapController mapController,
    required Function onLocationUpdated,
    double? newZoom,
  }) async {
    locationService.getRealTimeLocation((locationData) {
      currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);

      Marker currentlocationMarker = Marker(
        markerId: const MarkerId('current_loaction'),
        position: currentLatLng!,
      );

      markers.add(currentlocationMarker);
      onLocationUpdated();
      CameraPosition cameraPosition = CameraPosition(
        target: currentLatLng!,
        zoom: 17,
      );
      if (isFirstTime) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
        isFirstTime = false;
      } else {
        newZoom == null
            ? mapController.animateCamera(
                CameraUpdate.newLatLng(currentLatLng!),
              )
            : mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: currentLatLng!, zoom: newZoom),
                ),
              );
      }
    });
  }

  Future<List<LatLng>> getRoute({required LatLng destinationLatLng}) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLatLng!.latitude,
          longitude: currentLatLng!.longitude,
        ),
      ),
    );

    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destinationLatLng.latitude,
          longitude: destinationLatLng.longitude,
        ),
      ),
    );

    RoutesModel routes = await routesService.getRoutes(
      origin: origin,
      destination: destination,
    );
    List<LatLng> points = decodepolylines(routes);
    return points;
  }

  List<LatLng> decodepolylines(RoutesModel routes) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );
    List<LatLng> points = result
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
    return points;
  }

  void getPolylines(
    List<LatLng> points, {
    required Set<Polyline> polylines,
    required Set<Marker> markers,
    required GoogleMapController mapController,
  }) {
    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: Colors.blue,
      width: 5,
      startCap: Cap.roundCap,
    );
    polylines.add(route);
    Marker destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: points.last,
    );
    markers.add(destinationMarker);
    LatLngBounds bounds = getLatLngBounds(points);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    double southwestLat = points.first.latitude;
    double southwestLng = points.first.longitude;
    double northeastLat = points.first.latitude;
    double northeastLng = points.first.longitude;
    for (var point in points) {
      southwestLat = min(southwestLat, point.latitude);
      southwestLng = min(southwestLng, point.longitude);
      northeastLat = max(northeastLat, point.latitude);
      northeastLng = max(northeastLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  Future<LatLng> getPlaceDetails({required placeId}) async {
    return await placeService.getPlaceDetails(placeId: placeId);
  }
}
