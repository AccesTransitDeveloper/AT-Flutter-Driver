import '../booking/booking_detail_response.dart';

class GetVehicleTypeResponse {
  final List<VehicleTypeItem>? normalList;
  final List<VehicleTypeItem>? shareList;
  final List<VehicleTypeItem>? rentalList;
  final List<VehicleTypeItem>? openBookingList;
  final List<CustomPrice>? customPrices;
  final int? distance;
  final int? time;
  final List<int>? bookingTypeOrder;
  final VehicleTypeCitySetting? citySetting;

  GetVehicleTypeResponse({
    this.normalList,
    this.shareList,
    this.rentalList,
    this.openBookingList,
    this.customPrices,
    this.distance,
    this.time,
    this.bookingTypeOrder,
    this.citySetting,
  });

  factory GetVehicleTypeResponse.fromJson(Map<String, dynamic> json) =>
      GetVehicleTypeResponse(
        normalList: (json['normalList'] as List<dynamic>?)
            ?.map((e) => VehicleTypeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        shareList: (json['shareList'] as List<dynamic>?)
            ?.map((e) => VehicleTypeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        rentalList: (json['rentalList'] as List<dynamic>?)
            ?.map((e) => VehicleTypeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        openBookingList: (json['openBookingList'] as List<dynamic>?)
            ?.map((e) => VehicleTypeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customPrices: (json['customPrices'] as List<dynamic>?)
            ?.map((e) => CustomPrice.fromJson(e as Map<String, dynamic>))
            .toList(),
        distance: (json['distance'] as num?)?.toInt(),
        time: (json['time'] as num?)?.toInt(),
        bookingTypeOrder: (json['bookingTypeOrder'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList(),
        citySetting: json['citySetting'] == null
            ? null
            : VehicleTypeCitySetting.fromJson(
                json['citySetting'] as Map<String, dynamic>),
      );
}

class VehicleTypeCitySetting {
  final VehicleTypeBusinessSetting? businessSetting;
  final VehicleTypeDriverSettings? driverSetting;
  final int? maxStopLimit;

  VehicleTypeCitySetting({this.businessSetting, this.driverSetting, this.maxStopLimit});

  factory VehicleTypeCitySetting.fromJson(Map<String, dynamic> json) =>
      VehicleTypeCitySetting(
        businessSetting: json['businessSetting'] == null
            ? null
            : VehicleTypeBusinessSetting.fromJson(
                json['businessSetting'] as Map<String, dynamic>),
        driverSetting: json['driverSetting'] == null
            ? null
            : VehicleTypeDriverSettings.fromJson(
                json['driverSetting'] as Map<String, dynamic>),
        maxStopLimit: (json['maxStopLimit'] as num?)?.toInt(),
      );
}

class VehicleTypeBusinessSetting {
  final List<String>? normal;
  final List<String>? rental;
  final List<String>? share;

  VehicleTypeBusinessSetting({this.normal, this.rental, this.share});

  factory VehicleTypeBusinessSetting.fromJson(Map<String, dynamic> json) =>
      VehicleTypeBusinessSetting(
        normal: (json['NORMAL'] as List<dynamic>?)?.map((e) => e as String).toList(),
        rental: (json['RENTAL'] as List<dynamic>?)?.map((e) => e as String).toList(),
        share: (json['SHARE'] as List<dynamic>?)?.map((e) => e as String).toList(),
      );

  bool checkAvailability(String key, int rideType) {
    List<String>? list;
    switch (rideType) {
      case 1: list = normal; break;
      case 2: list = share; break;
      case 3: list = rental; break;
      default: list = normal;
    }
    return list?.contains(key) == true;
  }
}

class VehicleTypeDriverSettings {
  final VehicleTypeRideScheduleSetting? normal;
  final VehicleTypeRideScheduleSetting? rental;
  final VehicleTypeRideScheduleSetting? share;

  VehicleTypeDriverSettings({this.normal, this.rental, this.share});

  factory VehicleTypeDriverSettings.fromJson(Map<String, dynamic> json) =>
      VehicleTypeDriverSettings(
        normal: json['NORMAL'] == null
            ? null
            : VehicleTypeRideScheduleSetting.fromJson(
                json['NORMAL'] as Map<String, dynamic>),
        rental: json['RENTAL'] == null
            ? null
            : VehicleTypeRideScheduleSetting.fromJson(
                json['RENTAL'] as Map<String, dynamic>),
        share: json['SHARE'] == null
            ? null
            : VehicleTypeRideScheduleSetting.fromJson(
                json['SHARE'] as Map<String, dynamic>),
      );

  int? getMaxBookingDays(int rideType) {
    switch (rideType) {
      case 1: return normal?.schedule?.maxBookingDays;
      case 2: return share?.schedule?.maxBookingDays;
      case 3: return rental?.schedule?.maxBookingDays;
      default: return normal?.schedule?.maxBookingDays;
    }
  }
}

class VehicleTypeRideScheduleSetting {
  final VehicleTypeSchedule? schedule;

  VehicleTypeRideScheduleSetting({this.schedule});

  factory VehicleTypeRideScheduleSetting.fromJson(Map<String, dynamic> json) =>
      VehicleTypeRideScheduleSetting(
        schedule: json['SCHEDULE'] == null
            ? null
            : VehicleTypeSchedule.fromJson(
                json['SCHEDULE'] as Map<String, dynamic>),
      );
}

class VehicleTypeSchedule {
  final int? maxBookingDays;

  VehicleTypeSchedule({this.maxBookingDays});

  factory VehicleTypeSchedule.fromJson(Map<String, dynamic> json) =>
      VehicleTypeSchedule(
        maxBookingDays: (json['maxBookingDays'] as num?)?.toInt(),
      );
}

class VehicleTypeItem {
  final String? id;
  final InvoiceData? priceDetail;
  final String? vehicleTypeId;
  final String? itemPrice;

  VehicleTypeItem({
    this.id,
    this.priceDetail,
    this.vehicleTypeId,
    this.itemPrice,
  });

  factory VehicleTypeItem.fromJson(Map<String, dynamic> json) =>
      VehicleTypeItem(
        id: json['_id'] as String?,
        priceDetail: json['priceDetail'] == null
            ? null
            : InvoiceData.fromJson(
                json['priceDetail'] as Map<String, dynamic>),
        vehicleTypeId: json['vehicleTypeId'] as String?,
        itemPrice: json['itemPrice'] as String?,
      );
}

class CustomPrice {
  final String? id;
  final String? title;

  CustomPrice({this.id, this.title});

  factory CustomPrice.fromJson(Map<String, dynamic> json) => CustomPrice(
        id: json['_id'] as String?,
        title: json['title'] as String?,
      );
}
