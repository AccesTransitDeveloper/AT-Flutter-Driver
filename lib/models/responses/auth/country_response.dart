class CountryResponse {
  final List<Country>? countries;

  CountryResponse({this.countries});

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      countries: (json['countries'] as List<dynamic>?)
          ?.map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Country {
  final String? id;
  final String? name;
  final List<String>? phoneCodes;
  final String? currencyCode;
  final String? currencySign;
  final String? alpha2;
  final String? code;
  final String? code2;
  final List<String>? timezones;
  final bool? isBusiness;
  final String? phoneCode;

  Country({
    this.id,
    this.name,
    this.phoneCodes,
    this.currencyCode,
    this.currencySign,
    this.alpha2,
    this.code,
    this.code2,
    this.timezones,
    this.isBusiness,
    this.phoneCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phoneCodes: (json['phoneCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      currencyCode: json['currencyCode'] as String?,
      currencySign: json['currencySign'] as String?,
      alpha2: json['alpha2'] as String?,
      code: json['code'] as String?,
      code2: json['code2'] as String?,
      timezones: (json['timezones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isBusiness: json['isBusiness'] as bool?,
      phoneCode: json['phoneCode'] as String?,
    );
  }

  Country copyWith({List<String>? phoneCodes}) {
    return Country(
      id: id,
      name: name,
      phoneCodes: phoneCodes ?? this.phoneCodes,
      currencyCode: currencyCode,
      currencySign: currencySign,
      alpha2: alpha2,
      code: code,
      code2: code2,
      timezones: timezones,
      isBusiness: isBusiness,
      phoneCode: phoneCode,
    );
  }

  String get displayPhoneCode {
    if (phoneCode != null && phoneCode!.isNotEmpty) {
      return phoneCode!;
    }
    if (phoneCodes != null && phoneCodes!.isNotEmpty) {
      return phoneCodes!.first;
    }
    return '';
  }

  bool doesMatchSearchQuery(String query) {
    final matchingCombinations = [
      name ?? '',
      phoneCode ?? '',
      code ?? '',
    ];

    return matchingCombinations.any(
      (it) => it.toLowerCase().contains(query.toLowerCase()),
    );
  }
}
