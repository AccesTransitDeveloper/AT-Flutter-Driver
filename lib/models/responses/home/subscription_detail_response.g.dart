// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionVehicleInfoResponse _$SubscriptionVehicleInfoResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionVehicleInfoResponse(
  vehicleSubscription: json['vehicleSubscription'] == null
      ? null
      : VehicleSubscription.fromJson(
          json['vehicleSubscription'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SubscriptionVehicleInfoResponseToJson(
  SubscriptionVehicleInfoResponse instance,
) => <String, dynamic>{'vehicleSubscription': instance.vehicleSubscription};

VehicleSubscription _$VehicleSubscriptionFromJson(
  Map<String, dynamic> json,
) => VehicleSubscription(
  id: json['_id'] as String?,
  type: (json['type'] as num?)?.toInt(),
  typeId: json['typeId'] as String?,
  subscriptionId: json['subscriptionId'] as String?,
  status: (json['status'] as num?)?.toInt(),
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  subscription: json['subscription'] == null
      ? null
      : SubscriptionInfo.fromJson(json['subscription'] as Map<String, dynamic>),
  usageSubscription: json['usageSubscription'] == null
      ? null
      : SubscriptionPackage.fromJson(
          json['usageSubscription'] as Map<String, dynamic>,
        ),
  remainingTimeInMillis: (json['remainingTimeInMillis'] as num?)?.toDouble(),
);

Map<String, dynamic> _$VehicleSubscriptionToJson(
  VehicleSubscription instance,
) => <String, dynamic>{
  '_id': instance.id,
  'type': instance.type,
  'typeId': instance.typeId,
  'subscriptionId': instance.subscriptionId,
  'status': instance.status,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'subscription': instance.subscription,
  'usageSubscription': instance.usageSubscription,
  'remainingTimeInMillis': instance.remainingTimeInMillis,
};

SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    SubscriptionInfo(
      id: json['_id'] as String?,
      subscriptionPeriod: (json['subscriptionPeriod'] as num?)?.toInt(),
      cityIds: (json['cityIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      countryId: json['countryId'] as String?,
      vehicleTypeId: json['vehicleTypeId'] as String?,
      vehicleTypeName: json['vehicleTypeName'] as String?,
      subscriptionPackage: json['package'] == null
          ? null
          : SubscriptionPackage.fromJson(
              json['package'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SubscriptionInfoToJson(SubscriptionInfo instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'subscriptionPeriod': instance.subscriptionPeriod,
      'cityIds': instance.cityIds,
      'countryId': instance.countryId,
      'vehicleTypeId': instance.vehicleTypeId,
      'vehicleTypeName': instance.vehicleTypeName,
      'package': instance.subscriptionPackage,
    };

SubscriptionPackage _$SubscriptionPackageFromJson(Map<String, dynamic> json) =>
    SubscriptionPackage(
      freeTrial: json['freeTrial'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['freeTrial'] as Map<String, dynamic>,
            ),
      extraBookingsAdminProfit: json['extraBookingsAdminProfit'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['extraBookingsAdminProfit'] as Map<String, dynamic>,
            ),
      maxCanceledBookingsAllowed: json['maxCanceledBookingsAllowed'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxCanceledBookingsAllowed'] as Map<String, dynamic>,
            ),
      maxBiddingBookingsAllowed: json['maxBiddingBookingsAllowed'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxBiddingBookingsAllowed'] as Map<String, dynamic>,
            ),
      maxBookingsReceivedPerDay: json['maxBookingsReceivedPerDay'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxBookingsReceivedPerDay'] as Map<String, dynamic>,
            ),
      maxScheduledRidesPerDay: json['maxScheduledRidesPerDay'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxScheduledRidesPerDay'] as Map<String, dynamic>,
            ),
      maxDailyRevenue: json['maxDailyRevenue'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxDailyRevenue'] as Map<String, dynamic>,
            ),
      maxTotalRevenue: json['maxTotalRevenue'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxTotalRevenue'] as Map<String, dynamic>,
            ),
      maxExtraBookingsAllowed: json['maxExtraBookingsAllowed'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxExtraBookingsAllowed'] as Map<String, dynamic>,
            ),
      maxPreferredLocationChanges: json['maxPreferredLocationChanges'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxPreferredLocationChanges'] as Map<String, dynamic>,
            ),
      minWalletBalance: json['minWalletBalance'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['minWalletBalance'] as Map<String, dynamic>,
            ),
      maxBidAmount: json['maxBidAmount'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['maxBidAmount'] as Map<String, dynamic>,
            ),
      minBidAmount: json['minBidAmount'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['minBidAmount'] as Map<String, dynamic>,
            ),
      radiusIncreaseXTimes: json['radiusIncreaseXTimes'] == null
          ? null
          : SubscriptionPackageValue.fromJson(
              json['radiusIncreaseXTimes'] as Map<String, dynamic>,
            ),
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      adminProfit: (json['adminProfit'] as num?)?.toDouble(),
      currentAdminProfit: (json['currentAdminProfit'] as num?)?.toDouble(),
      isMarketplaceAccess: json['isMarketplaceAccess'] as bool?,
      isApplyIncentive: json['isApplyIncentive'] as bool?,
      isApplyPenalty: json['isApplyPenalty'] as bool?,
      isApplyReward: json['isApplyReward'] as bool?,
    );

Map<String, dynamic> _$SubscriptionPackageToJson(
  SubscriptionPackage instance,
) => <String, dynamic>{
  'freeTrial': instance.freeTrial,
  'extraBookingsAdminProfit': instance.extraBookingsAdminProfit,
  'maxCanceledBookingsAllowed': instance.maxCanceledBookingsAllowed,
  'maxBiddingBookingsAllowed': instance.maxBiddingBookingsAllowed,
  'maxBookingsReceivedPerDay': instance.maxBookingsReceivedPerDay,
  'maxScheduledRidesPerDay': instance.maxScheduledRidesPerDay,
  'maxDailyRevenue': instance.maxDailyRevenue,
  'maxTotalRevenue': instance.maxTotalRevenue,
  'maxExtraBookingsAllowed': instance.maxExtraBookingsAllowed,
  'maxPreferredLocationChanges': instance.maxPreferredLocationChanges,
  'minWalletBalance': instance.minWalletBalance,
  'maxBidAmount': instance.maxBidAmount,
  'minBidAmount': instance.minBidAmount,
  'radiusIncreaseXTimes': instance.radiusIncreaseXTimes,
  'name': instance.name,
  'price': instance.price,
  'adminProfit': instance.adminProfit,
  'currentAdminProfit': instance.currentAdminProfit,
  'isMarketplaceAccess': instance.isMarketplaceAccess,
  'isApplyIncentive': instance.isApplyIncentive,
  'isApplyPenalty': instance.isApplyPenalty,
  'isApplyReward': instance.isApplyReward,
};

SubscriptionPackageValue _$SubscriptionPackageValueFromJson(
  Map<String, dynamic> json,
) => SubscriptionPackageValue(
  isActive: json['isActive'] as bool?,
  isLimitOver: json['isLimitOver'] as bool?,
  days: (json['days'] as num?)?.toDouble(),
  value: (json['value'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SubscriptionPackageValueToJson(
  SubscriptionPackageValue instance,
) => <String, dynamic>{
  'isActive': instance.isActive,
  'isLimitOver': instance.isLimitOver,
  'days': instance.days,
  'value': instance.value,
};
