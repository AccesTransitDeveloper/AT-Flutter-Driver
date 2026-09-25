// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incentive_policy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncentivePolicyResponse _$IncentivePolicyResponseFromJson(
  Map<String, dynamic> json,
) => IncentivePolicyResponse(
  incentivePolicies: (json['incentivePolicies'] as List<dynamic>?)
      ?.map((e) => IncentivePolicy.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$IncentivePolicyResponseToJson(
  IncentivePolicyResponse instance,
) => <String, dynamic>{'incentivePolicies': instance.incentivePolicies};

IncentivePolicy _$IncentivePolicyFromJson(Map<String, dynamic> json) =>
    IncentivePolicy(
      incentive: json['incentive'] as String?,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$IncentivePolicyToJson(IncentivePolicy instance) =>
    <String, dynamic>{
      'incentive': instance.incentive,
      'conditions': instance.conditions,
    };
