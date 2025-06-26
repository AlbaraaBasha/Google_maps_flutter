import 'package:flutter/material.dart';
import 'package:google_maps_section/screens/route_tracker_app.dart';

void main() {
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RouteTrackerApp(),
    );
  }
}
