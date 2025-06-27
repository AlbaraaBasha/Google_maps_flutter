import 'package:flutter/material.dart';
import 'package:google_maps_section/models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({super.key, required this.places});

  final List<PlaceAutocompleteModel> places;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index].description!),
            trailing: const Icon(Icons.arrow_forward_sharp),
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.location_on_outlined),
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
