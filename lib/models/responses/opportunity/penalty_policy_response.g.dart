// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_policy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PenaltyPolicyResponse _$PenaltyPolicyResponseFromJson(
  Map<String, dynamic> json,
) => PenaltyPolicyResponse(
  penaltyPolicy: (json['penaltyPolicy'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PenaltyPolicyResponseToJson(
  PenaltyPolicyResponse instance,
) => <String, dynamic>{'penaltyPolicy': instance.penaltyPolicy};
