class CityResponse {
  final List<City>? cities;

  CityResponse({this.cities});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      cities: (json['cities'] as List<dynamic>?)
          ?.map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class City {
  final String? id;
  final String? name;
  final String? countryId;
  final bool? isBusiness;

  City({
    this.id,
    this.name,
    this.countryId,
    this.isBusiness,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      countryId: json['countryId'] as String?,
      isBusiness: json['isBusiness'] as bool?,
    );
  }

  bool doesMatchSearchQuery(String query) {
    final matchingCombinations = [
      name ?? '',
    ];

    return matchingCombinations.any(
      (it) => it.toLowerCase().contains(query.toLowerCase()),
    );
  }
}
