// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityDetailResponse _$EntityDetailResponseFromJson(
  Map<String, dynamic> json,
) => EntityDetailResponse(
  entity: json['entity'] == null
      ? null
      : Entity.fromJson(json['entity'] as Map<String, dynamic>),
  setting: json['setting'] == null
      ? null
      : Setting.fromJson(json['setting'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EntityDetailResponseToJson(
  EntityDetailResponse instance,
) => <String, dynamic>{'entity': instance.entity, 'setting': instance.setting};

Entity _$EntityFromJson(Map<String, dynamic> json) => Entity(
  type: (json['type'] as num?)?.toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  countryPhoneCode: json['countryPhoneCode'] as String?,
  phone: json['phone'] as String?,
  countryId: json['countryId'] as String?,
  cityId: json['cityId'] as String?,
  countryCode: json['countryCode'] as String?,
  drivingLicense: json['drivingLicense'] as String?,
  checkrCheck: json['checkrCheck'] == null
      ? null
      : CheckrCheckStatus.fromJson(json['checkrCheck'] as Map<String, dynamic>),
  imageUrl: json['imageUrl'] as String?,
  credit: (json['credit'] as num?)?.toDouble(),
  creditCurrencyCode: json['creditCurrencyCode'] as String?,
  earning: (json['earning'] as num?)?.toDouble(),
  reward: (json['reward'] as num?)?.toDouble(),
  status: (json['status'] as num?)?.toInt(),
  rate: (json['rate'] as num?)?.toDouble(),
  rateCount: (json['rateCount'] as num?)?.toInt(),
  uniqueId: _uniqueIdFromJson(json['uniqueId']),
  loginBy: (json['loginBy'] as num?)?.toInt(),
  isSocialAccount: json['isSocialAccount'] as bool?,
  profilePicStatus: (json['profilePicStatus'] as num?)?.toInt(),
  documentStatus: (json['documentStatus'] as num?)?.toInt(),
  referralDetail: json['referralDetail'] == null
      ? null
      : ReferralDetail.fromJson(json['referralDetail'] as Map<String, dynamic>),
  preferredLanguage: json['preferedLanguage'] as String?,
  speakingLanguages: (json['speakingLanguages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  bookingIds: (json['bookingIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  fixedGroupBookingIds: (json['fixedGroupBookingIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  runningFixedGroupBookingIds:
      (json['runningFixedGroupBookingIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  scheduleBookingIds: (json['scheduleBookingIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isVehicleAdded: json['isVehicleAdded'] as bool?,
  isDriverVehicleRequired: json['isDriverVehicleRequired'] as bool?,
  isMerchantService: json['isMerchantService'] as bool?,
  merchantId: json['merchantId'] as String?,
  businessAddress: json['businessAddress'] as String?,
  businessTypes: (json['businessTypes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  workflowTypes: (json['workflowTypes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  mainCategoryIds: (json['mainCategoryIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  priceModes: (json['priceModes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  zoneQueueNumber: (json['zoneQueueNumber'] as num?)?.toInt(),
  isAllowPickupFromHome: json['isAllowPickupFromHome'] as bool?,
  isAllowDropAtHome: json['isAllowDropAtHome'] as bool?,
  typeId: json['typeId'] as String?,
  fuelCapacity: (json['fuelCapacity'] as num?)?.toDouble(),
  totalFuelCapacity: (json['totalFuelCapacity'] as num?)?.toDouble(),
  vehicleType: json['vehicleType'] == null
      ? null
      : EntityVehicleType.fromJson(json['vehicleType'] as Map<String, dynamic>),
  selectedAddress: json['selectedAddress'] == null
      ? null
      : DriverSavedAddress.fromJson(
          json['selectedAddress'] as Map<String, dynamic>,
        ),
  id: json['id'] as String?,
);

Map<String, dynamic> _$EntityToJson(Entity instance) => <String, dynamic>{
  'type': instance.type,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'countryPhoneCode': instance.countryPhoneCode,
  'phone': instance.phone,
  'countryId': instance.countryId,
  'cityId': instance.cityId,
  'countryCode': instance.countryCode,
  'drivingLicense': instance.drivingLicense,
  'checkrCheck': instance.checkrCheck,
  'imageUrl': instance.imageUrl,
  'credit': instance.credit,
  'creditCurrencyCode': instance.creditCurrencyCode,
  'earning': instance.earning,
  'reward': instance.reward,
  'status': instance.status,
  'rate': instance.rate,
  'rateCount': instance.rateCount,
  'uniqueId': _uniqueIdToJson(instance.uniqueId),
  'loginBy': instance.loginBy,
  'isSocialAccount': instance.isSocialAccount,
  'profilePicStatus': instance.profilePicStatus,
  'documentStatus': instance.documentStatus,
  'referralDetail': instance.referralDetail,
  'preferedLanguage': instance.preferredLanguage,
  'speakingLanguages': instance.speakingLanguages,
  'roles': instance.roles,
  'bookingIds': instance.bookingIds,
  'fixedGroupBookingIds': instance.fixedGroupBookingIds,
  'runningFixedGroupBookingIds': instance.runningFixedGroupBookingIds,
  'scheduleBookingIds': instance.scheduleBookingIds,
  'isVehicleAdded': instance.isVehicleAdded,
  'isDriverVehicleRequired': instance.isDriverVehicleRequired,
  'isMerchantService': instance.isMerchantService,
  'merchantId': instance.merchantId,
  'businessAddress': instance.businessAddress,
  'businessTypes': instance.businessTypes,
  'workflowTypes': instance.workflowTypes,
  'mainCategoryIds': instance.mainCategoryIds,
  'priceModes': instance.priceModes,
  'zoneQueueNumber': instance.zoneQueueNumber,
  'isAllowPickupFromHome': instance.isAllowPickupFromHome,
  'isAllowDropAtHome': instance.isAllowDropAtHome,
  'typeId': instance.typeId,
  'fuelCapacity': instance.fuelCapacity,
  'totalFuelCapacity': instance.totalFuelCapacity,
  'vehicleType': instance.vehicleType,
  'selectedAddress': instance.selectedAddress,
  'id': instance.id,
};

ReferralDetail _$ReferralDetailFromJson(Map<String, dynamic> json) =>
    ReferralDetail(
      referralCode: json['referralCode'] as String?,
      referralUse: (json['referralUse'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReferralDetailToJson(ReferralDetail instance) =>
    <String, dynamic>{
      'referralCode': instance.referralCode,
      'referralUse': instance.referralUse,
    };

EntityVehicleType _$EntityVehicleTypeFromJson(Map<String, dynamic> json) =>
    EntityVehicleType(mapPinUrl: json['mapPinUrl'] as String?);

Map<String, dynamic> _$EntityVehicleTypeToJson(EntityVehicleType instance) =>
    <String, dynamic>{'mapPinUrl': instance.mapPinUrl};

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
  passwordRule: json['passwordRule'] == null
      ? null
      : PasswordRule.fromJson(json['passwordRule'] as Map<String, dynamic>),
  referralConfiguration: json['referralConfiguration'] == null
      ? null
      : ReferralConfiguration.fromJson(
          json['referralConfiguration'] as Map<String, dynamic>,
        ),
  referralPolicy: (json['referralPolicy'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  creditTransferConfig: json['creditTransferConfig'] == null
      ? null
      : CreditTransferConfig.fromJson(
          json['creditTransferConfig'] as Map<String, dynamic>,
        ),
  rewardPointConfig: json['rewardPointConfig'] == null
      ? null
      : RewardPointConfig.fromJson(
          json['rewardPointConfig'] as Map<String, dynamic>,
        ),
  appVersionDetail: json['appVersionDetail'] == null
      ? null
      : AppVersionDetail.fromJson(
          json['appVersionDetail'] as Map<String, dynamic>,
        ),
  appForceUpdate: json['appForceUpdate'] == null
      ? null
      : AppForceUpdate.fromJson(json['appForceUpdate'] as Map<String, dynamic>),
  appSetting: json['appSetting'] == null
      ? null
      : AppSetting.fromJson(json['appSetting'] as Map<String, dynamic>),
  flutterAppSetting: json['flutterAppSetting'] == null
      ? null
      : AppSetting.fromJson(json['flutterAppSetting'] as Map<String, dynamic>),
  mapKey: _mapKeyFromJson(json['mapKey']),
  contactDetail: json['contactDetail'] == null
      ? null
      : ContactDetail.fromJson(json['contactDetail'] as Map<String, dynamic>),
  minPhoneLength: (json['minPhoneLength'] as num?)?.toInt(),
  maxPhoneLength: (json['maxPhoneLength'] as num?)?.toInt(),
  decimalPointValue: (json['decimalPointValue'] as num?)?.toInt(),
  roundingMethod: (json['roundingMethod'] as num?)?.toDouble(),
  timeFormat: json['timeFormat'] as String?,
  setCurrencySign: (json['setCurrencySign'] as num?)?.toInt(),
  distanceUnit: (json['distanceUnit'] as num?)?.toInt(),
  currencySign: json['currencySign'] as String?,
  termsAndConditionsURL: json['termsAndConditionsURL'] as String?,
  privacyPolicyURL: json['privacyPolicyURL'] as String?,
  entitySetting: json['entitySetting'] == null
      ? null
      : EntitySetting.fromJson(json['entitySetting'] as Map<String, dynamic>),
  googleServerClientId: json['googleServerClientId'] as String?,
  themeSetting: json['themeSetting'] == null
      ? null
      : ThemeSetting.fromJson(json['themeSetting'] as Map<String, dynamic>),
  tagColor: json['tagColor'] == null
      ? null
      : TagColors.fromJson(json['tagColor'] as Map<String, dynamic>),
  mapType: (json['mapType'] as num?)?.toInt(),
  mapThemeSetting: json['mapThemeSetting'] == null
      ? null
      : MapThemeSetting.fromJson(
          json['mapThemeSetting'] as Map<String, dynamic>,
        ),
  subscriptionConfig: json['subscriptionConfig'] == null
      ? null
      : SubscriptionConfig.fromJson(
          json['subscriptionConfig'] as Map<String, dynamic>,
        ),
  splashScreen: json['splashScreen'] == null
      ? null
      : SplashData.fromJson(json['splashScreen'] as Map<String, dynamic>),
  pushNotificationSounds: (json['pushNotificationSounds'] as List<dynamic>?)
      ?.map((e) => PushNotificationSounds.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
  'passwordRule': instance.passwordRule,
  'referralConfiguration': instance.referralConfiguration,
  'referralPolicy': instance.referralPolicy,
  'creditTransferConfig': instance.creditTransferConfig,
  'rewardPointConfig': instance.rewardPointConfig,
  'appVersionDetail': instance.appVersionDetail,
  'appForceUpdate': instance.appForceUpdate,
  'appSetting': instance.appSetting,
  'flutterAppSetting': instance.flutterAppSetting,
  'mapKey': instance.mapKey,
  'contactDetail': instance.contactDetail,
  'minPhoneLength': instance.minPhoneLength,
  'maxPhoneLength': instance.maxPhoneLength,
  'decimalPointValue': instance.decimalPointValue,
  'roundingMethod': instance.roundingMethod,
  'timeFormat': instance.timeFormat,
  'setCurrencySign': instance.setCurrencySign,
  'distanceUnit': instance.distanceUnit,
  'currencySign': instance.currencySign,
  'termsAndConditionsURL': instance.termsAndConditionsURL,
  'privacyPolicyURL': instance.privacyPolicyURL,
  'entitySetting': instance.entitySetting,
  'googleServerClientId': instance.googleServerClientId,
  'themeSetting': instance.themeSetting,
  'tagColor': instance.tagColor,
  'mapType': instance.mapType,
  'mapThemeSetting': instance.mapThemeSetting,
  'subscriptionConfig': instance.subscriptionConfig,
  'splashScreen': instance.splashScreen,
  'pushNotificationSounds': instance.pushNotificationSounds,
};

PasswordRule _$PasswordRuleFromJson(Map<String, dynamic> json) => PasswordRule(
  minLength: (json['minLength'] as num?)?.toInt(),
  requireNumbers: json['requireNumbers'] as bool?,
  requireSpecial: json['requireSpecial'] as bool?,
  requireUppercase: json['requireUppercase'] as bool?,
  requireLowercase: json['requireLowercase'] as bool?,
  regEx: json['regEx'] as String?,
);

Map<String, dynamic> _$PasswordRuleToJson(PasswordRule instance) =>
    <String, dynamic>{
      'minLength': instance.minLength,
      'requireNumbers': instance.requireNumbers,
      'requireSpecial': instance.requireSpecial,
      'requireUppercase': instance.requireUppercase,
      'requireLowercase': instance.requireLowercase,
      'regEx': instance.regEx,
    };

SplashData _$SplashDataFromJson(Map<String, dynamic> json) =>
    SplashData(splashPath: json['driverAppSplashScreen'] as String?);

Map<String, dynamic> _$SplashDataToJson(SplashData instance) =>
    <String, dynamic>{'driverAppSplashScreen': instance.splashPath};

ReferralConfiguration _$ReferralConfigurationFromJson(
  Map<String, dynamic> json,
) => ReferralConfiguration(
  customer: json['CUSTOMER'] == null
      ? null
      : ReferralInfo.fromJson(json['CUSTOMER'] as Map<String, dynamic>),
  driver: json['DRIVER'] == null
      ? null
      : ReferralInfo.fromJson(json['DRIVER'] as Map<String, dynamic>),
  isShowReferralHistory: json['isShowReferralHistory'] as bool? ?? false,
);

Map<String, dynamic> _$ReferralConfigurationToJson(
  ReferralConfiguration instance,
) => <String, dynamic>{
  'CUSTOMER': instance.customer,
  'DRIVER': instance.driver,
  'isShowReferralHistory': instance.isShowReferralHistory,
};

ReferralInfo _$ReferralInfoFromJson(Map<String, dynamic> json) =>
    ReferralInfo(isActive: json['isActive'] as bool?);

Map<String, dynamic> _$ReferralInfoToJson(ReferralInfo instance) =>
    <String, dynamic>{'isActive': instance.isActive};

AppVersionDetail _$AppVersionDetailFromJson(Map<String, dynamic> json) =>
    AppVersionDetail(
      androidCustomer: json['androidCustomer'] as String?,
      androidDriver: json['androidDriver'] as String?,
      iosCustomer: json['iosCustomer'] as String?,
      iosDriver: json['iosDriver'] as String?,
    );

Map<String, dynamic> _$AppVersionDetailToJson(AppVersionDetail instance) =>
    <String, dynamic>{
      'androidCustomer': instance.androidCustomer,
      'androidDriver': instance.androidDriver,
      'iosCustomer': instance.iosCustomer,
      'iosDriver': instance.iosDriver,
    };

AppForceUpdate _$AppForceUpdateFromJson(Map<String, dynamic> json) =>
    AppForceUpdate(
      androidCustomer: json['androidCustomer'] as bool?,
      androidDriver: json['androidDriver'] as bool?,
      iosCustomer: json['iosCustomer'] as bool?,
      iosDriver: json['iosDriver'] as bool?,
    );

Map<String, dynamic> _$AppForceUpdateToJson(AppForceUpdate instance) =>
    <String, dynamic>{
      'androidCustomer': instance.androidCustomer,
      'androidDriver': instance.androidDriver,
      'iosCustomer': instance.iosCustomer,
      'iosDriver': instance.iosDriver,
    };

AppSetting _$AppSettingFromJson(Map<String, dynamic> json) => AppSetting(
  url: json['url'] as String?,
  version: json['version'] as String?,
  forceUpdate: json['forceUpdate'] as bool?,
);

Map<String, dynamic> _$AppSettingToJson(AppSetting instance) =>
    <String, dynamic>{
      'url': instance.url,
      'version': instance.version,
      'forceUpdate': instance.forceUpdate,
    };

MapKey _$MapKeyFromJson(Map<String, dynamic> json) => MapKey(
  mapKey: json['mapKey'] as String?,
  placesAutoCompleteApiKey: json['placesAutoCompleteApiKey'] as String?,
  distanceMatrixApiKey: json['distanceMatrixApiKey'] as String?,
  geocodingApiKey: json['geocodingApiKey'] as String?,
  directionsApiKey: json['directionsApiKey'] as String?,
  isAllowInAppNavigation: json['isAllowInAppNavigation'] as bool? ?? false,
);

Map<String, dynamic> _$MapKeyToJson(MapKey instance) => <String, dynamic>{
  'mapKey': instance.mapKey,
  'placesAutoCompleteApiKey': instance.placesAutoCompleteApiKey,
  'distanceMatrixApiKey': instance.distanceMatrixApiKey,
  'geocodingApiKey': instance.geocodingApiKey,
  'directionsApiKey': instance.directionsApiKey,
  'isAllowInAppNavigation': instance.isAllowInAppNavigation,
};

ContactDetail _$ContactDetailFromJson(Map<String, dynamic> json) =>
    ContactDetail(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$ContactDetailToJson(ContactDetail instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
    };

EntitySetting _$EntitySettingFromJson(Map<String, dynamic> json) =>
    EntitySetting(
      isSkipLogin: json['isSkipLogin'] as bool?,
      isAllowDeleteAccount: json['isAllowDeleteAccount'] as bool?,
      isMandatory: (json['isMandatory'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      isVerification: (json['isVerification'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      loginBy: json['loginBy'] == null
          ? null
          : LoginBy.fromJson(json['loginBy'] as Map<String, dynamic>),
      deleteBy: (json['deleteBy'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      maxFailLoginAttempt: (json['maxFailLoginAttempt'] as num?)?.toInt(),
      loginBlockDurationMinutes: (json['loginBlockDurationMinutes'] as num?)
          ?.toInt(),
      secOtpResendInterval: (json['secOtpResendInterval'] as num?)?.toInt(),
      resendOtpLimit: (json['resendOtpLimit'] as num?)?.toInt(),
      otpBlockDuration: (json['otpBlockDuration'] as num?)?.toInt(),
      otpBlockAction: json['otpBlockAction'] as String?,
    );

Map<String, dynamic> _$EntitySettingToJson(EntitySetting instance) =>
    <String, dynamic>{
      'isSkipLogin': instance.isSkipLogin,
      'isAllowDeleteAccount': instance.isAllowDeleteAccount,
      'isMandatory': instance.isMandatory,
      'isVerification': instance.isVerification,
      'loginBy': instance.loginBy,
      'deleteBy': instance.deleteBy,
      'maxFailLoginAttempt': instance.maxFailLoginAttempt,
      'loginBlockDurationMinutes': instance.loginBlockDurationMinutes,
      'secOtpResendInterval': instance.secOtpResendInterval,
      'resendOtpLimit': instance.resendOtpLimit,
      'otpBlockDuration': instance.otpBlockDuration,
      'otpBlockAction': instance.otpBlockAction,
    };

LoginBy _$LoginByFromJson(Map<String, dynamic> json) => LoginBy(
  phone: (json['phone'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  email: (json['email'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  social: (json['social'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$LoginByToJson(LoginBy instance) => <String, dynamic>{
  'phone': instance.phone,
  'email': instance.email,
  'social': instance.social,
};

ThemeSetting _$ThemeSettingFromJson(Map<String, dynamic> json) => ThemeSetting(
  lightMode: json['lightMode'] == null
      ? null
      : ThemeColors.fromJson(json['lightMode'] as Map<String, dynamic>),
  darkMode: json['darkMode'] == null
      ? null
      : ThemeColors.fromJson(json['darkMode'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ThemeSettingToJson(ThemeSetting instance) =>
    <String, dynamic>{
      'lightMode': instance.lightMode,
      'darkMode': instance.darkMode,
    };

TagColors _$TagColorsFromJson(Map<String, dynamic> json) => TagColors(
  lightMode: json['lightMode'] == null
      ? null
      : TagColor.fromJson(json['lightMode'] as Map<String, dynamic>),
  darkMode: json['darkMode'] == null
      ? null
      : TagColor.fromJson(json['darkMode'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TagColorsToJson(TagColors instance) => <String, dynamic>{
  'lightMode': instance.lightMode,
  'darkMode': instance.darkMode,
};

TagColor _$TagColorFromJson(Map<String, dynamic> json) => TagColor(
  normal: json['NORMAL'] as String?,
  share: json['SHARE'] as String?,
  rental: json['RENTAL'] as String?,
  openBooking: json['OPEN_BOOKING'] as String?,
  now: json['NOW'] as String?,
  schedule: json['SCHEDULE'] as String?,
  bidding: json['BIDDING'] as String?,
  multipleLocation: json['MULTIPLE_LOCATION'] as String?,
  fixFare: json['FIX_FARE'] as String?,
  cityToCity: json['CITY_TO_CITY'] as String?,
  zone: json['ZONE'] as String?,
  airport: json['AIRPORT'] as String?,
  destinationLater: json['DESTINATION_LATER'] as String?,
  splitPayment: json['SPLIT_PAYMENT'] as String?,
  returnTag: json['RETURN'] as String?,
  redZone: json['RED_ZONE'] as String?,
  guestToken: json['GUEST_TOKEN'] as String?,
  outsideBoundary: json['OUTSIDE_BOUNDARY'] as String?,
  quickCommerce: json['QUICK_COMMERCE'] as String?,
  delivery: json['DELIVERY'] as String?,
  pickup: json['PICKUP'] as String?,
  onSiteService: json['ON_SITE_SERVICE'] as String?,
  serviceAtHome: json['SERVICE_AT_HOME'] as String?,
  onlineService: json['ONLINE_SERVICE'] as String?,
  pickupFromHome: json['PICKUP_FROM_HOME'] as String?,
  dropAtHome: json['DROP_AT_HOME'] as String?,
  fallbackBooking: json['FALLBACK_BOOKING'] as String?,
  fixGroupBooking: json['FIX_GROUP_BOOKING'] as String?,
  weekly: json['WEEKLY'] as String?,
  intraCityCourier: json['INTRA_CITY_COURIER'] as String?,
  interCityCourier: json['INTER_CITY_COURIER'] as String?,
  mover: json['MOVER'] as String?,
);

Map<String, dynamic> _$TagColorToJson(TagColor instance) => <String, dynamic>{
  'NORMAL': instance.normal,
  'SHARE': instance.share,
  'RENTAL': instance.rental,
  'OPEN_BOOKING': instance.openBooking,
  'NOW': instance.now,
  'SCHEDULE': instance.schedule,
  'BIDDING': instance.bidding,
  'MULTIPLE_LOCATION': instance.multipleLocation,
  'FIX_FARE': instance.fixFare,
  'CITY_TO_CITY': instance.cityToCity,
  'ZONE': instance.zone,
  'AIRPORT': instance.airport,
  'DESTINATION_LATER': instance.destinationLater,
  'SPLIT_PAYMENT': instance.splitPayment,
  'RETURN': instance.returnTag,
  'RED_ZONE': instance.redZone,
  'GUEST_TOKEN': instance.guestToken,
  'OUTSIDE_BOUNDARY': instance.outsideBoundary,
  'QUICK_COMMERCE': instance.quickCommerce,
  'DELIVERY': instance.delivery,
  'PICKUP': instance.pickup,
  'ON_SITE_SERVICE': instance.onSiteService,
  'SERVICE_AT_HOME': instance.serviceAtHome,
  'ONLINE_SERVICE': instance.onlineService,
  'PICKUP_FROM_HOME': instance.pickupFromHome,
  'DROP_AT_HOME': instance.dropAtHome,
  'FALLBACK_BOOKING': instance.fallbackBooking,
  'FIX_GROUP_BOOKING': instance.fixGroupBooking,
  'WEEKLY': instance.weekly,
  'INTRA_CITY_COURIER': instance.intraCityCourier,
  'INTER_CITY_COURIER': instance.interCityCourier,
  'MOVER': instance.mover,
};

MapThemeSetting _$MapThemeSettingFromJson(Map<String, dynamic> json) =>
    MapThemeSetting(
      lightMode: json['lightMode'] as String?,
      darkMode: json['darkMode'] as String?,
    );

Map<String, dynamic> _$MapThemeSettingToJson(MapThemeSetting instance) =>
    <String, dynamic>{
      'lightMode': instance.lightMode,
      'darkMode': instance.darkMode,
    };

SubscriptionConfig _$SubscriptionConfigFromJson(Map<String, dynamic> json) =>
    SubscriptionConfig(
      isActive: json['isActive'] as bool?,
      isOptional: json['isOptional'] as bool?,
      paymentGateway: (json['paymentGateway'] as num?)?.toInt(),
      isAllowSubscriptionUpgrade:
          json['isAllowSubscriptionUpgrade'] as bool? ?? false,
    );

Map<String, dynamic> _$SubscriptionConfigToJson(SubscriptionConfig instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'isOptional': instance.isOptional,
      'paymentGateway': instance.paymentGateway,
      'isAllowSubscriptionUpgrade': instance.isAllowSubscriptionUpgrade,
    };

PushNotificationSounds _$PushNotificationSoundsFromJson(
  Map<String, dynamic> json,
) => PushNotificationSounds(
  id: json['_id'] as String?,
  title: json['title'] as String?,
  fileUrl: json['fileUrl'] as String?,
);

Map<String, dynamic> _$PushNotificationSoundsToJson(
  PushNotificationSounds instance,
) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'fileUrl': instance.fileUrl,
};

CreditTransferConfig _$CreditTransferConfigFromJson(
  Map<String, dynamic> json,
) => CreditTransferConfig(
  isCustomerToCustomer: json['isCustomerToCustomer'] as bool?,
  isCustomerToDriver: json['isCustomerToDriver'] as bool?,
  isDriverToCustomer: json['isDriverToCustomer'] as bool?,
  isDriverToDriver: json['isDriverToDriver'] as bool?,
  transferUsing: (json['transferUsing'] as List<dynamic>?)
      ?.map((e) => (e as num?)?.toInt())
      .toList(),
);

Map<String, dynamic> _$CreditTransferConfigToJson(
  CreditTransferConfig instance,
) => <String, dynamic>{
  'isCustomerToCustomer': instance.isCustomerToCustomer,
  'isCustomerToDriver': instance.isCustomerToDriver,
  'isDriverToCustomer': instance.isDriverToCustomer,
  'isDriverToDriver': instance.isDriverToDriver,
  'transferUsing': instance.transferUsing,
};

RewardPointConfig _$RewardPointConfigFromJson(Map<String, dynamic> json) =>
    RewardPointConfig(
      isActive: json['isActive'] as bool?,
      minPointForWithdrawal: (json['minPointForWithdrawal'] as num?)?.toInt(),
      valueOfOneRewardPoint: (json['valueOfOneRewardPoint'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$RewardPointConfigToJson(RewardPointConfig instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'minPointForWithdrawal': instance.minPointForWithdrawal,
      'valueOfOneRewardPoint': instance.valueOfOneRewardPoint,
    };

CheckrCheckStatus _$CheckrCheckStatusFromJson(Map<String, dynamic> json) =>
    CheckrCheckStatus(
      status: (json['status'] as num?)?.toInt(),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$CheckrCheckStatusToJson(CheckrCheckStatus instance) =>
    <String, dynamic>{'status': instance.status, 'id': instance.id};
