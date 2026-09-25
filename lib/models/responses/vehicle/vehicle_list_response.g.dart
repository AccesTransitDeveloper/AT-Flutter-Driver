// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleListResponse _$VehicleListResponseFromJson(Map<String, dynamic> json) =>
    VehicleListResponse(
      vehiclePrice: json['vehiclePrice'] == null
          ? null
          : VehiclePrice.fromJson(json['vehiclePrice'] as Map<String, dynamic>),
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleListResponseToJson(
  VehicleListResponse instance,
) => <String, dynamic>{
  'vehiclePrice': instance.vehiclePrice,
  'vehicles': instance.vehicles,
};

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
  accessibilityIds: (json['accessibilityIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  brandDetail: json['brandDetail'] == null
      ? null
      : Brand.fromJson(json['brandDetail'] as Map<String, dynamic>),
  brandId: json['brandId'] as String?,
  color: json['color'] as String?,
  countryId: json['countryId'] as String?,
  createdAt: json['createdAt'] as String?,
  documentStatus: (json['documentStatus'] as num?)?.toInt(),
  driverId: json['driverId'] as String?,
  id: json['_id'] as String?,
  isVehicleSelected: json['isVehicleSelected'] as bool?,
  modelDetail: json['modelDetail'] == null
      ? null
      : VehicleModel.fromJson(json['modelDetail'] as Map<String, dynamic>),
  modelId: json['modelId'] as String?,
  name: json['name'] as String?,
  plateNo: json['plateNo'] as String?,
  vehicleLicense: json['vehicleLicense'] as String?,
  status: (json['status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  typeId: json['typeId'] as String?,
  uniqueId: _dynamicToString(json['uniqueId']),
  updatedAt: json['updatedAt'] as String?,
  vehicleType: (json['vehicleType'] as num?)?.toInt(),
  vehicleTypeDetail: json['vehicleTypeDetail'] == null
      ? null
      : VehicleTypeDetail.fromJson(
          json['vehicleTypeDetail'] as Map<String, dynamic>,
        ),
  vehicleTypeId: json['vehicleTypeId'] as String?,
  year: json['year'] as String?,
  fallbackTypeIds: (json['fallbackTypeIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'accessibilityIds': instance.accessibilityIds,
  'brandDetail': instance.brandDetail,
  'brandId': instance.brandId,
  'color': instance.color,
  'countryId': instance.countryId,
  'createdAt': instance.createdAt,
  'documentStatus': instance.documentStatus,
  'driverId': instance.driverId,
  '_id': instance.id,
  'isVehicleSelected': instance.isVehicleSelected,
  'modelDetail': instance.modelDetail,
  'modelId': instance.modelId,
  'name': instance.name,
  'plateNo': instance.plateNo,
  'vehicleLicense': instance.vehicleLicense,
  'status': instance.status,
  'type': instance.type,
  'typeId': instance.typeId,
  'uniqueId': instance.uniqueId,
  'updatedAt': instance.updatedAt,
  'vehicleType': instance.vehicleType,
  'vehicleTypeDetail': instance.vehicleTypeDetail,
  'vehicleTypeId': instance.vehicleTypeId,
  'year': instance.year,
  'fallbackTypeIds': instance.fallbackTypeIds,
};

VehicleTypeDetail _$VehicleTypeDetailFromJson(Map<String, dynamic> json) =>
    VehicleTypeDetail(
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      mapPinUrl: json['mapPinUrl'] as String?,
      fallbackTypes: (json['fallbackTypes'] as List<dynamic>?)
          ?.map((e) => FallBackType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleTypeDetailToJson(VehicleTypeDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'mapPinUrl': instance.mapPinUrl,
      'fallbackTypes': instance.fallbackTypes,
    };

FallBackType _$FallBackTypeFromJson(Map<String, dynamic> json) => FallBackType(
  vehicleTypeId: json['vehicleTypeId'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$FallBackTypeToJson(FallBackType instance) =>
    <String, dynamic>{
      'vehicleTypeId': instance.vehicleTypeId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

VehiclePrice _$VehiclePriceFromJson(Map<String, dynamic> json) => VehiclePrice(
  bookingFee: json['bookingFee'] == null
      ? null
      : PriceData.fromJson(json['bookingFee'] as Map<String, dynamic>),
  distancePrice: json['distancePrice'] == null
      ? null
      : PriceData.fromJson(json['distancePrice'] as Map<String, dynamic>),
  timePrice: json['timePrice'] == null
      ? null
      : PriceData.fromJson(json['timePrice'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VehiclePriceToJson(VehiclePrice instance) =>
    <String, dynamic>{
      'bookingFee': instance.bookingFee,
      'distancePrice': instance.distancePrice,
      'timePrice': instance.timePrice,
    };

PriceData _$PriceDataFromJson(Map<String, dynamic> json) => PriceData(
  value: (json['value'] as num?)?.toDouble(),
  type: (json['type'] as num?)?.toInt(),
);

Map<String, dynamic> _$PriceDataToJson(PriceData instance) => <String, dynamic>{
  'value': instance.value,
  'type': instance.type,
};

Brand _$BrandFromJson(Map<String, dynamic> json) =>
    Brand(id: json['_id'] as String?, name: json['name'] as String?);

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
};

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  brandId: json['brandId'] as String?,
  id: json['_id'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'brandId': instance.brandId,
      '_id': instance.id,
      'name': instance.name,
    };
