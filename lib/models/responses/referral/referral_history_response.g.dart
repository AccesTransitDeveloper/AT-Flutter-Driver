// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralHistoryResponse _$ReferralHistoryResponseFromJson(
  Map<String, dynamic> json,
) => ReferralHistoryResponse(
  referral: json['referral'] == null
      ? null
      : ReferralData.fromJson(json['referral'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReferralHistoryResponseToJson(
  ReferralHistoryResponse instance,
) => <String, dynamic>{'referral': instance.referral};

ReferralData _$ReferralDataFromJson(Map<String, dynamic> json) => ReferralData(
  referrals: (json['referrals'] as List<dynamic>?)
      ?.map((e) => ReferralUser.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReferralDataToJson(ReferralData instance) =>
    <String, dynamic>{'referrals': instance.referrals};

ReferralUser _$ReferralUserFromJson(Map<String, dynamic> json) => ReferralUser(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  countryPhoneCode: json['countryPhoneCode'] as String?,
  phone: json['phone'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ReferralUserToJson(ReferralUser instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'countryPhoneCode': instance.countryPhoneCode,
      'phone': instance.phone,
      'imageUrl': instance.imageUrl,
    };
