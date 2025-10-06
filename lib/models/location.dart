class LocationData {
  final String id;
  final String nameEn;
  final String nameFr;
  final List<Country> countries;

  LocationData({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    this.countries = const [],
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameFr: json['name_fr'] as String,
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((c) => Country.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Country {
  final String id;
  final String nameEn;
  final String nameFr;
  final List<Diocese> dioceses;

  Country({
    required this.id,
    required this.nameEn,
    required this.nameFr,
    this.dioceses = const [],
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameFr: json['name_fr'] as String,
      dioceses:
          (json['dioceses'] as List<dynamic>?)
              ?.map((d) => Diocese.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Diocese {
  final String id;
  final String nameEn;
  final String nameFr;

  Diocese({required this.id, required this.nameEn, required this.nameFr});

  factory Diocese.fromJson(Map<String, dynamic> json) {
    return Diocese(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameFr: json['name_fr'] as String,
    );
  }
}

class LocationHierarchy {
  final List<LocationData> continents;

  LocationHierarchy({required this.continents});

  factory LocationHierarchy.fromJson(Map<String, dynamic> json) {
    return LocationHierarchy(
      continents: (json['continents'] as List<dynamic>)
          .map((c) => LocationData.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
