import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/utils/google_maps_place_service.dart';
import 'package:google_maps_section/utils/location_services.dart';
import 'package:google_maps_section/widgets/custom_list_view.dart';
import 'package:google_maps_section/widgets/custom_text_field.dart';

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
  @override
  void initState() {
    searchController = TextEditingController();
    googleMapsPlaceService = GoogleMapsPlaceService();
    locationService = LocationServices();
    initialCameraPosition = const CameraPosition(
      target: LatLng(34, 34),
      zoom: 5,
    );
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
                CustomListView(places: places),
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
      LatLng currentLatLng = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      log('Current Location: ${locationData.latitude!}');
      Marker currentlocationMarker = Marker(
        markerId: MarkerId('current_loaction'),
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
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('GPS is not enabled.'),
        ),
      );
    } on LocationServicePermissionException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      if (searchController.text.isNotEmpty) {
        var result = await googleMapsPlaceService.getPredictions(
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
}
