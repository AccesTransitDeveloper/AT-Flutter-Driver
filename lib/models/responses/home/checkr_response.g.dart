// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkr_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckrData _$CheckrDataFromJson(Map<String, dynamic> json) => CheckrData(
  checkId: json['checkId'] as String?,
  candidateId: json['candidateId'] as String?,
  invitationId: json['invitationId'] as String?,
  reportId: json['reportId'] as String?,
  status: (json['status'] as num?)?.toInt(),
  continueUrl: json['continueUrl'] as String?,
);

Map<String, dynamic> _$CheckrDataToJson(CheckrData instance) =>
    <String, dynamic>{
      'checkId': instance.checkId,
      'candidateId': instance.candidateId,
      'invitationId': instance.invitationId,
      'reportId': instance.reportId,
      'status': instance.status,
      'continueUrl': instance.continueUrl,
    };
