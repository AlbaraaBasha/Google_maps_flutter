import 'dart:developer';

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
import 'package:google_maps_section/widgets/custom_list_view.dart';
import 'package:google_maps_section/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class RouteTrackerBody extends StatefulWidget {
  const RouteTrackerBody({super.key});

  @override
  State<RouteTrackerBody> createState() => _RouteTrackerBodyState();
}

class _RouteTrackerBodyState extends State<RouteTrackerBody> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  late LocationServices locationService;
  late GoogleMapsPlaceService googleMapsPlaceService;
  late TextEditingController searchController;
  late Uuid uuid;
  String? sessionToken;
  late RoutesService routesService;
  late LatLng currentLatLng;
  late LatLng destinationLatLng;
  @override
  void initState() {
    uuid = const Uuid();

    searchController = TextEditingController();
    googleMapsPlaceService = GoogleMapsPlaceService();
    locationService = LocationServices();
    initialCameraPosition = const CameraPosition(
      target: LatLng(34, 34),
      zoom: 5,
    );
    routesService = RoutesService();
    fetchPredictions();
    super.initState();
  }

  @override
  dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<PlaceAutocompleteModel> places = [];
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: markers,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: (controller) {
            mapController = controller;
            updateCurrentLocation();
          },
        ),
        Positioned(
          right: 0,
          left: 0,

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CostumTextField(searchController: searchController),
                CustomListView(
                  places: places,
                  googleMapsPlaceService: googleMapsPlaceService,

                  onPlaceSelected: (latlng) {
                    mapController.animateCamera(CameraUpdate.newLatLng(latlng));
                    places.clear();
                    searchController.clear();
                    sessionToken = null;
                    setState(() {});
                    destinationLatLng = latlng;
                    getRoute();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
      log('Current Location: ${locationData.latitude!}');
      Marker currentlocationMarker = Marker(
        markerId: const MarkerId('current_loaction'),
        position: currentLatLng,
      );
      setState(() {
        markers.add(currentlocationMarker);
      });
      CameraPosition cameraPosition = CameraPosition(
        target: currentLatLng,
        zoom: 15,
      );
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    } on LocationServiceGPSException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('GPS is not enabled.'),
        ),
      );
    } on LocationServicePermissionException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'No permission given! Please enable location permissions.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred while fetching location: $e'),
        ),
      );
    }
  }

  void fetchPredictions() {
    searchController.addListener(() async {
      sessionToken ??= uuid.v4();
      log(sessionToken!);
      if (searchController.text.isNotEmpty) {
        var result = await googleMapsPlaceService.getPredictions(
          sessionToken: sessionToken!,
          input: searchController.text,
        );
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  Future<List<LatLng>> getRoute() async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentLatLng.latitude,
          longitude: currentLatLng.longitude,
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
}
