// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missing_information_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissingInformationResponse _$MissingInformationResponseFromJson(
  Map<String, dynamic> json,
) => MissingInformationResponse(
  informationStatus: json['informationStatus'] == null
      ? null
      : InformationStatus.fromJson(
          json['informationStatus'] as Map<String, dynamic>,
        ),
  cashBookingMinimumWallet: (json['cashBookingMinimumWallet'] as num?)?.toInt(),
);

Map<String, dynamic> _$MissingInformationResponseToJson(
  MissingInformationResponse instance,
) => <String, dynamic>{
  'informationStatus': instance.informationStatus,
  'cashBookingMinimumWallet': instance.cashBookingMinimumWallet,
};

InformationStatus _$InformationStatusFromJson(Map<String, dynamic> json) =>
    InformationStatus(
      creditStatus: json['creditStatus'] as bool?,
      vehicleStatus: json['vehicleStatus'] as bool?,
      profileStatus: json['profileStatus'] as bool?,
      documentStatus: (json['documentStatus'] as num?)?.toInt(),
      subscriptionStatus: json['subscriptionStatus'] as bool?,
    );

Map<String, dynamic> _$InformationStatusToJson(InformationStatus instance) =>
    <String, dynamic>{
      'creditStatus': instance.creditStatus,
      'vehicleStatus': instance.vehicleStatus,
      'profileStatus': instance.profileStatus,
      'documentStatus': instance.documentStatus,
      'subscriptionStatus': instance.subscriptionStatus,
    };
