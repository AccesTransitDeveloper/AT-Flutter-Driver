import 'package:json_annotation/json_annotation.dart';

part 'country_city_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CountryCityRequest {
  final String? cityId;
  final String? countryId;

  CountryCityRequest({this.cityId, this.countryId});

  factory CountryCityRequest.fromJson(Map<String, dynamic> json) =>
      _$CountryCityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CountryCityRequestToJson(this);
}
