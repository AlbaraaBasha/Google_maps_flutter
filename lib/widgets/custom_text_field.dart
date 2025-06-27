import 'package:flutter/material.dart';

class CostumTextField extends StatelessWidget {
  const CostumTextField({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,

      decoration: InputDecoration(
        border: borderLine(),
        enabledBorder: borderLine(),
        focusedBorder: borderLine(),
        fillColor: Colors.white,
        filled: true,
        hintText: 'Search for places',
        suffixIcon: IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: () {},
        ),
      ),
    );
  }

  OutlineInputBorder borderLine() {
    return OutlineInputBorder(
      borderRadius: searchController.text.isNotEmpty
          ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )
          : const BorderRadius.all(Radius.circular(20)),
      borderSide: const BorderSide(color: Colors.transparent),
    );
  }
}
