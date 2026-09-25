// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contact_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyContactResponse _$EmergencyContactResponseFromJson(
  Map<String, dynamic> json,
) => EmergencyContactResponse(
  emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
      ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EmergencyContactResponseToJson(
  EmergencyContactResponse instance,
) => <String, dynamic>{'emergencyContacts': instance.emergencyContacts};

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      countryPhoneCode: json['countryPhoneCode'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'countryPhoneCode': instance.countryPhoneCode,
      'image': instance.image,
    };
