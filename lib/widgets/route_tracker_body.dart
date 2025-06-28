import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/utils/location_services.dart';
import 'package:google_maps_section/utils/map_services.dart';
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
  late MapServices mapServices;
  late GoogleMapController mapController;

  late TextEditingController searchController;
  late Uuid uuid;
  String? sessionToken;

  late LatLng currentLatLng;
  late LatLng destinationLatLng;
  @override
  void initState() {
    uuid = const Uuid();
    mapServices = MapServices();
    searchController = TextEditingController();

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

  Set<Polyline> polylines = {};
  List<PlaceAutocompleteModel> places = [];
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polylines,
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
                  mapServices: mapServices,

                  onPlaceSelected: (latlng) async {
                    mapController.animateCamera(CameraUpdate.newLatLng(latlng));
                    places.clear();
                    searchController.clear();
                    sessionToken = null;
                    setState(() {});
                    destinationLatLng = latlng;
                    var points = await mapServices.getRoute(
                      currentLatLng: currentLatLng,
                      destinationLatLng: destinationLatLng,
                    );
                    mapServices.getPolylines(
                      points,
                      polylines: polylines,
                      markers: markers,
                      mapController: mapController,
                    );
                    setState(() {});
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
      currentLatLng = await mapServices.updateCurrentLocation(
        markers: markers,
        mapController: mapController,
      );
      setState(() {});
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

      await mapServices.getPredictions(
        searchController: searchController,
        sessionToken: sessionToken,
        places: places,
      );
      setState(() {});
    });
  }
}
