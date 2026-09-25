// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancellation_reason_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancellationReasonResponse _$CancellationReasonResponseFromJson(
  Map<String, dynamic> json,
) => CancellationReasonResponse(
  cancellationReasons: (json['cancellationReasons'] as List<dynamic>?)
      ?.map((e) => CancellationReason.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CancellationReasonResponseToJson(
  CancellationReasonResponse instance,
) => <String, dynamic>{'cancellationReasons': instance.cancellationReasons};

CancellationReason _$CancellationReasonFromJson(Map<String, dynamic> json) =>
    CancellationReason(
      id: json['_id'] as String?,
      type: (json['type'] as num?)?.toInt(),
      businessType: (json['businessType'] as num?)?.toInt(),
      reasons: json['reasons'] as String?,
    );

Map<String, dynamic> _$CancellationReasonToJson(CancellationReason instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'type': instance.type,
      'businessType': instance.businessType,
      'reasons': instance.reasons,
    };
