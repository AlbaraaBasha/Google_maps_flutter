class AddressComponent {
  String? longName;
  String? shortName;
  List<dynamic>? types;

  AddressComponent({this.longName, this.shortName, this.types});

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] as String?,
      shortName: json['short_name'] as String?,
      types: json['types'],
    );
  }

  Map<String, dynamic> toJson() => {
    'long_name': longName,
    'short_name': shortName,
    'types': types,
  };
}
