import 'package:flutter/material.dart';
import 'package:google_maps_section/widgets/route_tracker_body.dart';

class RouteTrackerApp extends StatelessWidget {
  const RouteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: RouteTrackerBody());
  }
}
