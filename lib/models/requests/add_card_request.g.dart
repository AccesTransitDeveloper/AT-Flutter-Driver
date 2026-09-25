// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_card_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCardRequest _$AddCardRequestFromJson(Map<String, dynamic> json) =>
    AddCardRequest(
      countryId: json['countryId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );

Map<String, dynamic> _$AddCardRequestToJson(AddCardRequest instance) =>
    <String, dynamic>{
      'countryId': instance.countryId,
      'paymentMethod': instance.paymentMethod,
    };
