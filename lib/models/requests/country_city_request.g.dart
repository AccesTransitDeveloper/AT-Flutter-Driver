// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_city_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryCityRequest _$CountryCityRequestFromJson(Map<String, dynamic> json) =>
    CountryCityRequest(
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
    );

Map<String, dynamic> _$CountryCityRequestToJson(CountryCityRequest instance) =>
    <String, dynamic>{
      'cityId': ?instance.cityId,
      'countryId': ?instance.countryId,
    };
