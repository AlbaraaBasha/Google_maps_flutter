import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/places_model.dart';
import 'package:google_maps_section/screens/route_tracker_app.dart';
import 'package:google_maps_section/utils/location_services.dart';
import 'package:location/location.dart';

class GoogleMapsHomePageBody extends StatefulWidget {
  const GoogleMapsHomePageBody({super.key});

  @override
  State<GoogleMapsHomePageBody> createState() => _GoogleMapsHomePageBodyState();
}

class _GoogleMapsHomePageBodyState extends State<GoogleMapsHomePageBody> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  late LocationServices locationServices;
  bool isFirstCall = true;
  @override
  void initState() {
    locationServices = LocationServices();
    initialCameraPosition = const CameraPosition(
      target: LatLng(37.7749, -122.4194), // San Francisco coordinates
      zoom: 10,
    );
    // initMarkers();
    // initPolylines();
    // initPolygons();
    // initCircles();
    updateMyLocation();
    super.initState();
  }

  var darkstyle;
  Set<Marker> markers = {
    Marker(markerId: MarkerId('4'), position: LatLng(38.7749, -122.4194)),
  };

  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          circles: circles,
          polylines: polylines,
          polygons: polygons,
          markers: markers,
          style: darkstyle,
          initialCameraPosition: initialCameraPosition,
          onMapCreated: (controller) {
            mapController = controller;
          },
          //mapType: MapType.hybrid,
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 30,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                // mapController.animateCamera(
                //   CameraUpdate.newLatLng(LatLng(34, 37.5)),
                // );
                initMapStyle();
                setState(() {});
              },

              child: Text('Make action'),
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 30,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const RouteTrackerApp(),
                  ),
                );
              },
              child: Text('Next App'),
            ),
          ),
        ),
      ],
    );
  }

  void initMapStyle() async {
    darkstyle = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/map_styles/map_night_mode.json');
  }

  void initMarkers() async {
    var customMarkerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(100, 100)),
      'assets/images/marker1.png',
    );
    places
        .map(
          (places) => {
            markers.add(
              Marker(
                markerId: MarkerId(places.id),
                position: places.latLng,
                icon: customMarkerIcon,
                infoWindow: InfoWindow(title: places.name),
              ),
            ),
          },
        )
        .toSet();
    setState(() {});
  }

  void initPolylines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId('1'),
      color: Colors.red,
      width: 4,
      endCap: Cap.roundCap,
      points: [
        LatLng(35.25607406003138, -121.65591208284123),
        LatLng(37.8079, -122.47501),
        LatLng(36.54040290180585, -117.44889948731677),
        LatLng(33.49085410038133, -117.8460683560445),
      ],
    );
    polylines.add(polyline);
  }

  void initPolygons() {
    Polygon polygon = Polygon(
      holes: [
        [
          LatLng(37.8087, -122.4098), // Near Fisherman's Wharf (North)
          LatLng(37.8079, -122.4750), // Near Sea Cliff (Northwest)
          LatLng(37.7081, -122.5107), // Daly City border (Southwest)
        ],
      ],
      polygonId: PolygonId('san_francisco'),
      fillColor: Colors.green.withValues(alpha: 0.5),
      strokeColor: Colors.red,
      strokeWidth: 2,
      points: [
        LatLng(37.8087, -122.4098), // Near Fisherman's Wharf (North)
        LatLng(37.8079, -122.4750), // Near Sea Cliff (Northwest)
        LatLng(37.7081, -122.5107), // Daly City border (Southwest)
        LatLng(37.7076, -122.3918), // Bayview/Hunters Point (Southeast)
        LatLng(37.8100, -122.3900), // Near Pier 39/Embarcadero (Northeast)
        LatLng(37.8087, -122.4098), // Close the polygon
      ],
    );

    polygons.add(polygon);
  }

  void initCircles() {
    Circle circle = Circle(
      circleId: CircleId('1'),
      center: LatLng(37.7749, -122.4194),
      radius: 10000,
      fillColor: Colors.deepOrangeAccent.withValues(alpha: 0.3),
      strokeWidth: 3,
      strokeColor: Colors.deepPurple,
    );
    circles.add(circle);
  }

  void updateMyLocation() async {
    locationServices.getRealTimeLocation((locationData) {
      setMyLocationMarker(locationData);
      setCameraPosition(locationData);
    });
  }

  void setCameraPosition(LocationData locationData) {
    if (isFirstCall) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 17,
          ),
        ),
      );
      isFirstCall = false;
    } else {
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );
    }
  }

  void setMyLocationMarker(LocationData locationData) {
    markers.add(
      Marker(
        markerId: MarkerId('my_location_marker'),
        position: LatLng(locationData.latitude!, locationData.longitude!),
      ),
    );
    setState(() {});
  }
}
