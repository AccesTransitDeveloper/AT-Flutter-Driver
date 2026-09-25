import 'package:json_annotation/json_annotation.dart';

part 'subscription_detail_response.g.dart';

@JsonSerializable()
class SubscriptionVehicleInfoResponse {
  final VehicleSubscription? vehicleSubscription;

  SubscriptionVehicleInfoResponse({this.vehicleSubscription});

  factory SubscriptionVehicleInfoResponse.fromJson(
          Map<String, dynamic> json) =>
      _$SubscriptionVehicleInfoResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SubscriptionVehicleInfoResponseToJson(this);
}

@JsonSerializable()
class VehicleSubscription {
  @JsonKey(name: '_id')
  final String? id;
  final int? type;
  final String? typeId;
  final String? subscriptionId;
  final int? status;
  final String? startDate;
  final String? endDate;
  final SubscriptionInfo? subscription;
  final SubscriptionPackage? usageSubscription;
  final double? remainingTimeInMillis;

  VehicleSubscription({
    this.id,
    this.type,
    this.typeId,
    this.subscriptionId,
    this.status,
    this.startDate,
    this.endDate,
    this.subscription,
    this.usageSubscription,
    this.remainingTimeInMillis,
  });

  factory VehicleSubscription.fromJson(Map<String, dynamic> json) =>
      _$VehicleSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleSubscriptionToJson(this);
}

@JsonSerializable()
class SubscriptionInfo {
  @JsonKey(name: '_id')
  final String? id;
  final int? subscriptionPeriod;
  final List<String>? cityIds;
  final String? countryId;
  final String? vehicleTypeId;
  final String? vehicleTypeName;
  @JsonKey(name: 'package')
  final SubscriptionPackage? subscriptionPackage;

  SubscriptionInfo({
    this.id,
    this.subscriptionPeriod,
    this.cityIds,
    this.countryId,
    this.vehicleTypeId,
    this.vehicleTypeName,
    this.subscriptionPackage,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionInfoToJson(this);
}

@JsonSerializable()
class SubscriptionPackage {
  final SubscriptionPackageValue? freeTrial;
  final SubscriptionPackageValue? extraBookingsAdminProfit;
  final SubscriptionPackageValue? maxCanceledBookingsAllowed;
  final SubscriptionPackageValue? maxBiddingBookingsAllowed;
  final SubscriptionPackageValue? maxBookingsReceivedPerDay;
  final SubscriptionPackageValue? maxScheduledRidesPerDay;
  final SubscriptionPackageValue? maxDailyRevenue;
  final SubscriptionPackageValue? maxTotalRevenue;
  final SubscriptionPackageValue? maxExtraBookingsAllowed;
  final SubscriptionPackageValue? maxPreferredLocationChanges;
  final SubscriptionPackageValue? minWalletBalance;
  final SubscriptionPackageValue? maxBidAmount;
  final SubscriptionPackageValue? minBidAmount;
  final SubscriptionPackageValue? radiusIncreaseXTimes;
  final String? name;
  final double? price;
  final double? adminProfit;
  final double? currentAdminProfit;
  final bool? isMarketplaceAccess;
  final bool? isApplyIncentive;
  final bool? isApplyPenalty;
  final bool? isApplyReward;

  SubscriptionPackage({
    this.freeTrial,
    this.extraBookingsAdminProfit,
    this.maxCanceledBookingsAllowed,
    this.maxBiddingBookingsAllowed,
    this.maxBookingsReceivedPerDay,
    this.maxScheduledRidesPerDay,
    this.maxDailyRevenue,
    this.maxTotalRevenue,
    this.maxExtraBookingsAllowed,
    this.maxPreferredLocationChanges,
    this.minWalletBalance,
    this.maxBidAmount,
    this.minBidAmount,
    this.radiusIncreaseXTimes,
    this.name,
    this.price,
    this.adminProfit,
    this.currentAdminProfit,
    this.isMarketplaceAccess,
    this.isApplyIncentive,
    this.isApplyPenalty,
    this.isApplyReward,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPackageFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPackageToJson(this);
}

@JsonSerializable()
class SubscriptionPackageValue {
  final bool? isActive;
  final bool? isLimitOver;
  final double? days;
  final double? value;

  SubscriptionPackageValue({
    this.isActive,
    this.isLimitOver,
    this.days,
    this.value,
  });

  factory SubscriptionPackageValue.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPackageValueFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPackageValueToJson(this);
}
