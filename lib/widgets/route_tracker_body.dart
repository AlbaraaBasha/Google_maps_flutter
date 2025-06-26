import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/utils/location_services.dart';

class RouteTrackerBody extends StatefulWidget {
  const RouteTrackerBody({super.key});

  @override
  State<RouteTrackerBody> createState() => _RouteTrackerBodyState();
}

class _RouteTrackerBodyState extends State<RouteTrackerBody> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  late LocationServices locationService;
  @override
  void initState() {
    locationService = LocationServices();
    initialCameraPosition = const CameraPosition(
      target: LatLng(34, 34),
      zoom: 5,
    );

    super.initState();
  }

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (controller) {
        mapController = controller;
        updateCurrentLocation();
      },
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
}
