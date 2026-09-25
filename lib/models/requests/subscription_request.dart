import 'package:json_annotation/json_annotation.dart';

part 'subscription_request.g.dart';

@JsonSerializable()
class SubscriptionCreateRequest {
  final String? subscriptionId;

  SubscriptionCreateRequest({this.subscriptionId});

  factory SubscriptionCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionCreateRequestToJson(this);
}

@JsonSerializable()
class SubscriptionUpgradeRequest {
  final String? subscriptionId;

  SubscriptionUpgradeRequest({this.subscriptionId});

  factory SubscriptionUpgradeRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionUpgradeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionUpgradeRequestToJson(this);
}
