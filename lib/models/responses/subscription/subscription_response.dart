import 'package:json_annotation/json_annotation.dart';
import '../home/subscription_detail_response.dart';

part 'subscription_response.g.dart';

@JsonSerializable()
class SubscriptionResponse {
  final List<VehicleSubscription>? vehicleSubscriptions;
  final List<SubscriptionInfo>? subscriptions;

  SubscriptionResponse({this.vehicleSubscriptions, this.subscriptions});

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionResponseToJson(this);
}

@JsonSerializable()
class SubscriptionVehicleUpgradeResponse {
  final double? paidAmount;

  SubscriptionVehicleUpgradeResponse({this.paidAmount});

  factory SubscriptionVehicleUpgradeResponse.fromJson(
          Map<String, dynamic> json) =>
      _$SubscriptionVehicleUpgradeResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SubscriptionVehicleUpgradeResponseToJson(this);
}

@JsonSerializable()
class SubscriptionInvoiceResponse {
  final TransactionReference? transactionReference;

  SubscriptionInvoiceResponse({this.transactionReference});

  factory SubscriptionInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInvoiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionInvoiceResponseToJson(this);
}

@JsonSerializable()
class TransactionReference {
  final String? status;
  final String? url;

  TransactionReference({this.status, this.url});

  factory TransactionReference.fromJson(Map<String, dynamic> json) =>
      _$TransactionReferenceFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionReferenceToJson(this);
}
