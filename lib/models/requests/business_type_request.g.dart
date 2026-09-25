// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_type_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessTypeRequest _$BusinessTypeRequestFromJson(Map<String, dynamic> json) =>
    BusinessTypeRequest(
      address: json['address'] == null
          ? null
          : BusinessTypeAddress.fromJson(
              json['address'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$BusinessTypeRequestToJson(
  BusinessTypeRequest instance,
) => <String, dynamic>{'address': instance.address};

BusinessTypeAddress _$BusinessTypeAddressFromJson(Map<String, dynamic> json) =>
    BusinessTypeAddress(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      countryCode: json['countryCode'] as String?,
    );

Map<String, dynamic> _$BusinessTypeAddressToJson(
  BusinessTypeAddress instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'countryCode': instance.countryCode,
};
