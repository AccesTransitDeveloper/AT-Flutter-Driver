// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchUserResponse _$SearchUserResponseFromJson(Map<String, dynamic> json) =>
    SearchUserResponse(
      user: json['user'] == null
          ? null
          : SearchUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchUserResponseToJson(SearchUserResponse instance) =>
    <String, dynamic>{'user': instance.user};

SearchUser _$SearchUserFromJson(Map<String, dynamic> json) => SearchUser(
  countryPhoneCode: json['countryPhoneCode'] as String?,
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  fullName: json['fullName'] as String?,
  fullPhone: json['fullPhone'] as String?,
  odooId: json['_id'] as String?,
  id: json['id'] as String?,
  imageUrl: json['imageUrl'] as String?,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String?,
  type: (json['type'] as num?)?.toInt(),
);

Map<String, dynamic> _$SearchUserToJson(SearchUser instance) =>
    <String, dynamic>{
      'countryPhoneCode': instance.countryPhoneCode,
      'email': instance.email,
      'firstName': instance.firstName,
      'fullName': instance.fullName,
      'fullPhone': instance.fullPhone,
      '_id': instance.odooId,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'type': instance.type,
    };
