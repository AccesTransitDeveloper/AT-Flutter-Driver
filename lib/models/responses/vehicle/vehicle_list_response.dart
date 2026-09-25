import 'package:json_annotation/json_annotation.dart';

part 'vehicle_list_response.g.dart';

@JsonSerializable()
class VehicleListResponse {
  final VehiclePrice? vehiclePrice;
  final List<Vehicle>? vehicles;

  VehicleListResponse({
    this.vehiclePrice,
    this.vehicles,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleListResponseToJson(this);
}

@JsonSerializable()
class Vehicle {
  final List<String>? accessibilityIds;
  final Brand? brandDetail;
  final String? brandId;
  final String? color;
  final String? countryId;
  final String? createdAt;
  final int? documentStatus;
  final String? driverId;
  @JsonKey(name: '_id')
  final String? id;
  final bool? isVehicleSelected;
  final VehicleModel? modelDetail;
  final String? modelId;
  final String? name;
  final String? plateNo;
  final String? vehicleLicense;
  final int? status;
  final int? type;
  final String? typeId;
  @JsonKey(fromJson: _dynamicToString)
  final String? uniqueId;
  final String? updatedAt;
  final int? vehicleType;
  final VehicleTypeDetail? vehicleTypeDetail;
  final String? vehicleTypeId;
  final String? year;
  final List<String>? fallbackTypeIds;

  Vehicle({
    this.accessibilityIds,
    this.brandDetail,
    this.brandId,
    this.color,
    this.countryId,
    this.createdAt,
    this.documentStatus,
    this.driverId,
    this.id,
    this.isVehicleSelected,
    this.modelDetail,
    this.modelId,
    this.name,
    this.plateNo,
    this.vehicleLicense,
    this.status,
    this.type,
    this.typeId,
    this.uniqueId,
    this.updatedAt,
    this.vehicleType,
    this.vehicleTypeDetail,
    this.vehicleTypeId,
    this.year,
    this.fallbackTypeIds,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}

@JsonSerializable()
class VehicleTypeDetail {
  final String? name;
  final String? imageUrl;
  final String? mapPinUrl;
  final List<FallBackType>? fallbackTypes;

  VehicleTypeDetail({
    this.name,
    this.imageUrl,
    this.mapPinUrl,
    this.fallbackTypes,
  });

  factory VehicleTypeDetail.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeDetailFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleTypeDetailToJson(this);
}

@JsonSerializable()
class FallBackType {
  final String? vehicleTypeId;
  final String? name;
  final String? imageUrl;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isChecked;

  FallBackType({
    this.vehicleTypeId,
    this.name,
    this.imageUrl,
    this.isChecked = false,
  });

  factory FallBackType.fromJson(Map<String, dynamic> json) =>
      _$FallBackTypeFromJson(json);

  Map<String, dynamic> toJson() => _$FallBackTypeToJson(this);
}

@JsonSerializable()
class VehiclePrice {
  final PriceData? bookingFee;
  final PriceData? distancePrice;
  final PriceData? timePrice;

  VehiclePrice({
    this.bookingFee,
    this.distancePrice,
    this.timePrice,
  });

  factory VehiclePrice.fromJson(Map<String, dynamic> json) =>
      _$VehiclePriceFromJson(json);

  Map<String, dynamic> toJson() => _$VehiclePriceToJson(this);
}

@JsonSerializable()
class PriceData {
  final double? value;
  final int? type;

  PriceData({
    this.value,
    this.type,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) =>
      _$PriceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PriceDataToJson(this);
}

@JsonSerializable()
class Brand {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  Brand({
    this.id,
    this.name,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);

  Map<String, dynamic> toJson() => _$BrandToJson(this);
}

@JsonSerializable()
class VehicleModel {
  final String? brandId;
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  VehicleModel({
    this.brandId,
    this.id,
    this.name,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}

/// Converts a dynamic value (String or int) to String?
String? _dynamicToString(dynamic value) => value?.toString();
