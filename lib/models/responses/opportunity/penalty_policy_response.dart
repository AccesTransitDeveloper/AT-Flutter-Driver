import 'package:json_annotation/json_annotation.dart';

part 'penalty_policy_response.g.dart';

@JsonSerializable()
class PenaltyPolicyResponse {
  final List<String>? penaltyPolicy;

  PenaltyPolicyResponse({this.penaltyPolicy});

  factory PenaltyPolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$PenaltyPolicyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PenaltyPolicyResponseToJson(this);
}
