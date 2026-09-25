// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_address_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddAddressRequest _$AddAddressRequestFromJson(Map<String, dynamic> json) =>
    AddAddressRequest(
      addressType: (json['addressType'] as num?)?.toInt(),
      title: json['title'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      countryCode: json['countryCode'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      placeId: json['placeId'] as String?,
    );

Map<String, dynamic> _$AddAddressRequestToJson(AddAddressRequest instance) =>
    <String, dynamic>{
      'addressType': instance.addressType,
      'title': instance.title,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'countryCode': instance.countryCode,
      'country': instance.country,
      'postalCode': instance.postalCode,
      'placeId': instance.placeId,
    };
