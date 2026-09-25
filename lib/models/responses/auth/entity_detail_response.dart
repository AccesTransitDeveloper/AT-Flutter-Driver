import 'package:json_annotation/json_annotation.dart';
import '../../theme_colors.dart';
import '../setting/address_response.dart';

part 'entity_detail_response.g.dart';

@JsonSerializable()
class EntityDetailResponse {
  final Entity? entity;
  final Setting? setting;

  EntityDetailResponse({this.entity, this.setting});

  factory EntityDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$EntityDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EntityDetailResponseToJson(this);
}

@JsonSerializable()
class Entity {
  final int? type;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? countryPhoneCode;
  final String? phone;
  final String? countryId;
  final String? cityId;
  final String? countryCode;
  final String? drivingLicense;
  final CheckrCheckStatus? checkrCheck;
  final String? imageUrl;
  final double? credit;
  final String? creditCurrencyCode;
  final double? earning;
  final double? reward;
  final int? status;
  final double? rate;
  final int? rateCount;
  @JsonKey(fromJson: _uniqueIdFromJson, toJson: _uniqueIdToJson)
  final String? uniqueId;
  final int? loginBy;
  final bool? isSocialAccount;
  final int? profilePicStatus;
  final int? documentStatus;
  final ReferralDetail? referralDetail;
  @JsonKey(name: 'preferedLanguage')
  final String? preferredLanguage;
  final List<String>? speakingLanguages;
  final List<String>? roles;
  final List<String>? bookingIds;
  final List<String>? fixedGroupBookingIds;
  final List<String>? runningFixedGroupBookingIds;
  final List<String>? scheduleBookingIds;
  final bool? isVehicleAdded;
  final bool? isDriverVehicleRequired;
  final bool? isMerchantService;
  final String? merchantId;
  final String? businessAddress;
  final List<int>? businessTypes;
  final List<int>? workflowTypes;
  final List<String>? mainCategoryIds;
  final List<int>? priceModes;
  final int? zoneQueueNumber;
  final bool? isAllowPickupFromHome;
  final bool? isAllowDropAtHome;
  final String? typeId;
  final double? fuelCapacity;
  final double? totalFuelCapacity;
  final EntityVehicleType? vehicleType;
  final DriverSavedAddress? selectedAddress;
  final String? id;

  Entity({
    this.type,
    this.firstName,
    this.lastName,
    this.email,
    this.countryPhoneCode,
    this.phone,
    this.countryId,
    this.cityId,
    this.countryCode,
    this.drivingLicense,
    this.checkrCheck,
    this.imageUrl,
    this.credit,
    this.creditCurrencyCode,
    this.earning,
    this.reward,
    this.status,
    this.rate,
    this.rateCount,
    this.uniqueId,
    this.loginBy,
    this.isSocialAccount,
    this.profilePicStatus,
    this.documentStatus,
    this.referralDetail,
    this.preferredLanguage,
    this.speakingLanguages,
    this.roles,
    this.bookingIds,
    this.fixedGroupBookingIds,
    this.runningFixedGroupBookingIds,
    this.scheduleBookingIds,
    this.isVehicleAdded,
    this.isDriverVehicleRequired,
    this.isMerchantService,
    this.merchantId,
    this.businessAddress,
    this.businessTypes,
    this.workflowTypes,
    this.mainCategoryIds,
    this.priceModes,
    this.zoneQueueNumber,
    this.isAllowPickupFromHome,
    this.isAllowDropAtHome,
    this.typeId,
    this.fuelCapacity,
    this.totalFuelCapacity,
    this.vehicleType,
    this.selectedAddress,
    this.id,
  });

  factory Entity.fromJson(Map<String, dynamic> json) =>
      _$EntityFromJson(json);

  Map<String, dynamic> toJson() => _$EntityToJson(this);
}

@JsonSerializable()
class ReferralDetail {
  final String? referralCode;
  final int? referralUse;

  ReferralDetail({this.referralCode, this.referralUse});

  factory ReferralDetail.fromJson(Map<String, dynamic> json) =>
      _$ReferralDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralDetailToJson(this);
}

@JsonSerializable()
class EntityVehicleType {
  final String? mapPinUrl;

  EntityVehicleType({this.mapPinUrl});

  factory EntityVehicleType.fromJson(Map<String, dynamic> json) =>
      _$EntityVehicleTypeFromJson(json);

  Map<String, dynamic> toJson() => _$EntityVehicleTypeToJson(this);
}

@JsonSerializable()
class Setting {
  final PasswordRule? passwordRule;
  final ReferralConfiguration? referralConfiguration;
  final List<String>? referralPolicy;
  final CreditTransferConfig? creditTransferConfig;
  final RewardPointConfig? rewardPointConfig;
  final AppVersionDetail? appVersionDetail;
  final AppForceUpdate? appForceUpdate;
  final AppSetting? appSetting;
  final AppSetting? flutterAppSetting;
  @JsonKey(fromJson: _mapKeyFromJson)
  final MapKey? mapKey;
  final ContactDetail? contactDetail;
  final int? minPhoneLength;
  final int? maxPhoneLength;
  final int? decimalPointValue;
  final double? roundingMethod;
  final String? timeFormat;
  final int? setCurrencySign;
  final int? distanceUnit;
  final String? currencySign;
  final String? termsAndConditionsURL;
  final String? privacyPolicyURL;
  final EntitySetting? entitySetting;
  final String? googleServerClientId;
  final ThemeSetting? themeSetting;
  final TagColors? tagColor;
  final int? mapType;
  final MapThemeSetting? mapThemeSetting;
  final SubscriptionConfig? subscriptionConfig;
  final SplashData? splashScreen;
  final List<PushNotificationSounds>? pushNotificationSounds;

  Setting({
    this.passwordRule,
    this.referralConfiguration,
    this.referralPolicy,
    this.creditTransferConfig,
    this.rewardPointConfig,
    this.appVersionDetail,
    this.appForceUpdate,
    this.appSetting,
    this.flutterAppSetting,
    this.mapKey,
    this.contactDetail,
    this.minPhoneLength,
    this.maxPhoneLength,
    this.decimalPointValue,
    this.roundingMethod,
    this.timeFormat,
    this.setCurrencySign,
    this.distanceUnit,
    this.currencySign,
    this.termsAndConditionsURL,
    this.privacyPolicyURL,
    this.entitySetting,
    this.googleServerClientId,
    this.themeSetting,
    this.tagColor,
    this.mapType,
    this.mapThemeSetting,
    this.subscriptionConfig,
    this.splashScreen,
    this.pushNotificationSounds,
  });

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}

@JsonSerializable()
class PasswordRule {
  final int? minLength;
  final bool? requireNumbers;
  final bool? requireSpecial;
  final bool? requireUppercase;
  final bool? requireLowercase;
  final String? regEx;

  PasswordRule({
    this.minLength,
    this.requireNumbers,
    this.requireSpecial,
    this.requireUppercase,
    this.requireLowercase,
    this.regEx,
  });

  factory PasswordRule.fromJson(Map<String, dynamic> json) =>
      _$PasswordRuleFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordRuleToJson(this);
}

@JsonSerializable()
class SplashData {
  @JsonKey(name: 'driverAppSplashScreen')
  final String? splashPath;

  SplashData({this.splashPath});

  factory SplashData.fromJson(Map<String, dynamic> json) =>
      _$SplashDataFromJson(json);

  Map<String, dynamic> toJson() => _$SplashDataToJson(this);
}

@JsonSerializable()
class ReferralConfiguration {
  @JsonKey(name: 'CUSTOMER')
  final ReferralInfo? customer;
  @JsonKey(name: 'DRIVER')
  final ReferralInfo? driver;
  final bool isShowReferralHistory;

  ReferralConfiguration({
    this.customer,
    this.driver,
    this.isShowReferralHistory = false,
  });

  factory ReferralConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ReferralConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralConfigurationToJson(this);
}

@JsonSerializable()
class ReferralInfo {
  final bool? isActive;

  ReferralInfo({this.isActive});

  factory ReferralInfo.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralInfoToJson(this);
}

@JsonSerializable()
class AppVersionDetail {
  final String? androidCustomer;
  final String? androidDriver;
  final String? iosCustomer;
  final String? iosDriver;

  AppVersionDetail({
    this.androidCustomer,
    this.androidDriver,
    this.iosCustomer,
    this.iosDriver,
  });

  factory AppVersionDetail.fromJson(Map<String, dynamic> json) =>
      _$AppVersionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionDetailToJson(this);
}

@JsonSerializable()
class AppForceUpdate {
  final bool? androidCustomer;
  final bool? androidDriver;
  final bool? iosCustomer;
  final bool? iosDriver;

  AppForceUpdate({
    this.androidCustomer,
    this.androidDriver,
    this.iosCustomer,
    this.iosDriver,
  });

  factory AppForceUpdate.fromJson(Map<String, dynamic> json) =>
      _$AppForceUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$AppForceUpdateToJson(this);
}

@JsonSerializable()
class AppSetting {
  final String? url;
  final String? version;
  final bool? forceUpdate;

  AppSetting({this.url, this.version, this.forceUpdate});

  factory AppSetting.fromJson(Map<String, dynamic> json) =>
      _$AppSettingFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingToJson(this);
}

@JsonSerializable()
class MapKey {
  final String? mapKey;
  final String? placesAutoCompleteApiKey;
  final String? distanceMatrixApiKey;
  final String? geocodingApiKey;
  final String? directionsApiKey;
  final bool isAllowInAppNavigation;

  MapKey({
    this.mapKey,
    this.placesAutoCompleteApiKey,
    this.distanceMatrixApiKey,
    this.geocodingApiKey,
    this.directionsApiKey,
    this.isAllowInAppNavigation = false,
  });

  factory MapKey.fromJson(Map<String, dynamic> json) =>
      _$MapKeyFromJson(json);

  Map<String, dynamic> toJson() => _$MapKeyToJson(this);
}

@JsonSerializable()
class ContactDetail {
  final String? email;
  final String? phone;
  final String? address;

  ContactDetail({this.email, this.phone, this.address});

  factory ContactDetail.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDetailToJson(this);
}

@JsonSerializable()
class EntitySetting {
  final bool? isSkipLogin;
  final bool? isAllowDeleteAccount;
  final List<int>? isMandatory;
  final List<int>? isVerification;
  final LoginBy? loginBy;
  final List<int>? deleteBy;
  final int? maxFailLoginAttempt;
  final int? loginBlockDurationMinutes;
  final int? secOtpResendInterval;
  final int? resendOtpLimit;
  final int? otpBlockDuration;
  final String? otpBlockAction;

  EntitySetting({
    this.isSkipLogin,
    this.isAllowDeleteAccount,
    this.isMandatory,
    this.isVerification,
    this.loginBy,
    this.deleteBy,
    this.maxFailLoginAttempt,
    this.loginBlockDurationMinutes,
    this.secOtpResendInterval,
    this.resendOtpLimit,
    this.otpBlockDuration,
    this.otpBlockAction,
  });

  factory EntitySetting.fromJson(Map<String, dynamic> json) =>
      _$EntitySettingFromJson(json);

  Map<String, dynamic> toJson() => _$EntitySettingToJson(this);
}

@JsonSerializable()
class LoginBy {
  final List<int>? phone;
  final List<int>? email;
  final List<int>? social;

  LoginBy({this.phone, this.email, this.social});

  factory LoginBy.fromJson(Map<String, dynamic> json) =>
      _$LoginByFromJson(json);

  Map<String, dynamic> toJson() => _$LoginByToJson(this);
}

@JsonSerializable()
class ThemeSetting {
  final ThemeColors? lightMode;
  final ThemeColors? darkMode;

  ThemeSetting({this.lightMode, this.darkMode});

  factory ThemeSetting.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeSettingToJson(this);
}

@JsonSerializable()
class TagColors {
  final TagColor? lightMode;
  final TagColor? darkMode;

  TagColors({this.lightMode, this.darkMode});

  factory TagColors.fromJson(Map<String, dynamic> json) =>
      _$TagColorsFromJson(json);

  Map<String, dynamic> toJson() => _$TagColorsToJson(this);
}

@JsonSerializable()
class TagColor {
  @JsonKey(name: 'NORMAL')
  final String? normal;
  @JsonKey(name: 'SHARE')
  final String? share;
  @JsonKey(name: 'RENTAL')
  final String? rental;
  @JsonKey(name: 'OPEN_BOOKING')
  final String? openBooking;
  @JsonKey(name: 'NOW')
  final String? now;
  @JsonKey(name: 'SCHEDULE')
  final String? schedule;
  @JsonKey(name: 'BIDDING')
  final String? bidding;
  @JsonKey(name: 'MULTIPLE_LOCATION')
  final String? multipleLocation;
  @JsonKey(name: 'FIX_FARE')
  final String? fixFare;
  @JsonKey(name: 'CITY_TO_CITY')
  final String? cityToCity;
  @JsonKey(name: 'ZONE')
  final String? zone;
  @JsonKey(name: 'AIRPORT')
  final String? airport;
  @JsonKey(name: 'DESTINATION_LATER')
  final String? destinationLater;
  @JsonKey(name: 'SPLIT_PAYMENT')
  final String? splitPayment;
  @JsonKey(name: 'RETURN')
  final String? returnTag;
  @JsonKey(name: 'RED_ZONE')
  final String? redZone;
  @JsonKey(name: 'GUEST_TOKEN')
  final String? guestToken;
  @JsonKey(name: 'OUTSIDE_BOUNDARY')
  final String? outsideBoundary;
  @JsonKey(name: 'QUICK_COMMERCE')
  final String? quickCommerce;
  @JsonKey(name: 'DELIVERY')
  final String? delivery;
  @JsonKey(name: 'PICKUP')
  final String? pickup;
  @JsonKey(name: 'ON_SITE_SERVICE')
  final String? onSiteService;
  @JsonKey(name: 'SERVICE_AT_HOME')
  final String? serviceAtHome;
  @JsonKey(name: 'ONLINE_SERVICE')
  final String? onlineService;
  @JsonKey(name: 'PICKUP_FROM_HOME')
  final String? pickupFromHome;
  @JsonKey(name: 'DROP_AT_HOME')
  final String? dropAtHome;
  @JsonKey(name: 'FALLBACK_BOOKING')
  final String? fallbackBooking;
  @JsonKey(name: 'FIX_GROUP_BOOKING')
  final String? fixGroupBooking;
  @JsonKey(name: 'WEEKLY')
  final String? weekly;
  @JsonKey(name: 'INTRA_CITY_COURIER')
  final String? intraCityCourier;
  @JsonKey(name: 'INTER_CITY_COURIER')
  final String? interCityCourier;
  @JsonKey(name: 'MOVER')
  final String? mover;

  TagColor({
    this.normal,
    this.share,
    this.rental,
    this.openBooking,
    this.now,
    this.schedule,
    this.bidding,
    this.multipleLocation,
    this.fixFare,
    this.cityToCity,
    this.zone,
    this.airport,
    this.destinationLater,
    this.splitPayment,
    this.returnTag,
    this.redZone,
    this.guestToken,
    this.outsideBoundary,
    this.quickCommerce,
    this.delivery,
    this.pickup,
    this.onSiteService,
    this.serviceAtHome,
    this.onlineService,
    this.pickupFromHome,
    this.dropAtHome,
    this.fallbackBooking,
    this.fixGroupBooking,
    this.weekly,
    this.intraCityCourier,
    this.interCityCourier,
    this.mover,
  });

  factory TagColor.fromJson(Map<String, dynamic> json) =>
      _$TagColorFromJson(json);

  Map<String, dynamic> toJson() => _$TagColorToJson(this);
}

@JsonSerializable()
class MapThemeSetting {
  final String? lightMode;
  final String? darkMode;

  MapThemeSetting({this.lightMode, this.darkMode});

  factory MapThemeSetting.fromJson(Map<String, dynamic> json) =>
      _$MapThemeSettingFromJson(json);

  Map<String, dynamic> toJson() => _$MapThemeSettingToJson(this);
}

@JsonSerializable()
class SubscriptionConfig {
  final bool? isActive;
  final bool? isOptional;
  final int? paymentGateway;
  final bool isAllowSubscriptionUpgrade;

  SubscriptionConfig({
    this.isActive,
    this.isOptional,
    this.paymentGateway,
    this.isAllowSubscriptionUpgrade = false,
  });

  factory SubscriptionConfig.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionConfigToJson(this);
}

@JsonSerializable()
class PushNotificationSounds {
  @JsonKey(name: '_id')
  final String? id;
  final String? title;
  final String? fileUrl;

  PushNotificationSounds({this.id, this.title, this.fileUrl});

  factory PushNotificationSounds.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationSoundsFromJson(json);

  Map<String, dynamic> toJson() => _$PushNotificationSoundsToJson(this);
}

@JsonSerializable()
class CreditTransferConfig {
  final bool? isCustomerToCustomer;
  final bool? isCustomerToDriver;
  final bool? isDriverToCustomer;
  final bool? isDriverToDriver;
  final List<int?>? transferUsing;

  CreditTransferConfig({
    this.isCustomerToCustomer,
    this.isCustomerToDriver,
    this.isDriverToCustomer,
    this.isDriverToDriver,
    this.transferUsing,
  });

  factory CreditTransferConfig.fromJson(Map<String, dynamic> json) =>
      _$CreditTransferConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CreditTransferConfigToJson(this);
}

@JsonSerializable()
class RewardPointConfig {
  final bool? isActive;
  final int? minPointForWithdrawal;
  final double? valueOfOneRewardPoint;

  RewardPointConfig({
    this.isActive,
    this.minPointForWithdrawal,
    this.valueOfOneRewardPoint,
  });

  factory RewardPointConfig.fromJson(Map<String, dynamic> json) =>
      _$RewardPointConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RewardPointConfigToJson(this);
}

// Helper: uniqueId comes as int from API, model uses String
String? _uniqueIdFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

dynamic _uniqueIdToJson(String? value) => value;

// Helper: mapKey comes as String or Map from API
MapKey? _mapKeyFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return MapKey(mapKey: value);
  if (value is Map<String, dynamic>) return MapKey.fromJson(value);
  return null;
}

/// Checkr background-check state carried on the entity. `status` maps to
/// [CheckrStatus].
@JsonSerializable()
class CheckrCheckStatus {
  final int? status;
  final String? id;

  CheckrCheckStatus({this.status, this.id});

  factory CheckrCheckStatus.fromJson(Map<String, dynamic> json) =>
      _$CheckrCheckStatusFromJson(json);

  Map<String, dynamic> toJson() => _$CheckrCheckStatusToJson(this);
}
