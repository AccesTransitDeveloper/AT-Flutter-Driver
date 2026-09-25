// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_type_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessTypeResponse _$BusinessTypeResponseFromJson(
  Map<String, dynamic> json,
) => BusinessTypeResponse(
  businessTypes: (json['businessTypes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  bookingTypes: (json['bookingTypes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$BusinessTypeResponseToJson(
  BusinessTypeResponse instance,
) => <String, dynamic>{
  'businessTypes': instance.businessTypes,
  'bookingTypes': instance.bookingTypes,
};
