// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => DriverSavedAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{'addresses': instance.addresses};

DriverSavedAddress _$DriverSavedAddressFromJson(Map<String, dynamic> json) =>
    DriverSavedAddress(
      id: json['_id'] as String?,
      address: json['address'] as String?,
      title: json['title'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      placeId: json['placeId'] as String?,
      isAddressSelected: json['isAddressSelected'] as bool?,
    );

Map<String, dynamic> _$DriverSavedAddressToJson(DriverSavedAddress instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'address': instance.address,
      'title': instance.title,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'country': instance.country,
      'countryCode': instance.countryCode,
      'placeId': instance.placeId,
      'isAddressSelected': instance.isAddressSelected,
    };
