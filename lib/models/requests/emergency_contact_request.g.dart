// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contact_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyContactRequest _$EmergencyContactRequestFromJson(
  Map<String, dynamic> json,
) => EmergencyContactRequest(
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  countryPhoneCode: json['countryPhoneCode'] as String?,
);

Map<String, dynamic> _$EmergencyContactRequestToJson(
  EmergencyContactRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'countryPhoneCode': instance.countryPhoneCode,
};
