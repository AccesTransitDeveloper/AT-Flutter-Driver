// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearest_hub_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearestHubListResponse _$NearestHubListResponseFromJson(
  Map<String, dynamic> json,
) => NearestHubListResponse(
  hubs: (json['hubs'] as List<dynamic>?)
      ?.map((e) => Hub.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NearestHubListResponseToJson(
  NearestHubListResponse instance,
) => <String, dynamic>{'hubs': instance.hubs};

Hub _$HubFromJson(Map<String, dynamic> json) => Hub(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  address: json['address'] == null
      ? null
      : HubAddress.fromJson(json['address'] as Map<String, dynamic>),
  locations: json['locations'] == null
      ? null
      : HubLocations.fromJson(json['locations'] as Map<String, dynamic>),
  distance: (json['distance'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HubToJson(Hub instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'locations': instance.locations,
  'distance': instance.distance,
};

HubAddress _$HubAddressFromJson(Map<String, dynamic> json) => HubAddress(
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HubAddressToJson(HubAddress instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

HubLocations _$HubLocationsFromJson(Map<String, dynamic> json) => HubLocations(
  type: json['type'] as String?,
  coordinates: (json['coordinates'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>)
            .map(
              (e) => (e as List<dynamic>)
                  .map((e) => (e as num).toDouble())
                  .toList(),
            )
            .toList(),
      )
      .toList(),
);

Map<String, dynamic> _$HubLocationsToJson(HubLocations instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
