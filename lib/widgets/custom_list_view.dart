import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:google_maps_section/utils/map_services.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places,
    required this.mapServices,

    required this.onPlaceSelected,
  });
  final void Function(LatLng latlng) onPlaceSelected;
  final List<PlaceAutocompleteModel> places;
  final MapServices mapServices;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index].description!),
            leading: const Icon(Icons.location_on_outlined),
            trailing: IconButton(
              onPressed: () async {
                LatLng result = await mapServices.getPlaceDetails(
                  placeId: places[index].placeId,
                );

                onPlaceSelected(result);
              },
              icon: const Icon(Icons.arrow_forward_sharp),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: places.length,
      ),
    );
  }
}
