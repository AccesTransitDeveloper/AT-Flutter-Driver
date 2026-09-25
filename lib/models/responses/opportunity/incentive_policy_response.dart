import 'package:json_annotation/json_annotation.dart';

part 'incentive_policy_response.g.dart';

@JsonSerializable()
class IncentivePolicyResponse {
  final List<IncentivePolicy>? incentivePolicies;

  IncentivePolicyResponse({this.incentivePolicies});

  factory IncentivePolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$IncentivePolicyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IncentivePolicyResponseToJson(this);
}

@JsonSerializable()
class IncentivePolicy {
  final String? incentive;
  final List<String>? conditions;

  IncentivePolicy({this.incentive, this.conditions});

  factory IncentivePolicy.fromJson(Map<String, dynamic> json) =>
      _$IncentivePolicyFromJson(json);

  Map<String, dynamic> toJson() => _$IncentivePolicyToJson(this);
}
