import 'package:json_annotation/json_annotation.dart';

part 'nearest_hub_list_response.g.dart';

@JsonSerializable()
class NearestHubListResponse {
  final List<Hub>? hubs;

  NearestHubListResponse({this.hubs});

  factory NearestHubListResponse.fromJson(Map<String, dynamic> json) =>
      _$NearestHubListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NearestHubListResponseToJson(this);
}

@JsonSerializable()
class Hub {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final HubAddress? address;
  final HubLocations? locations;
  final double? distance;

  Hub({this.id, this.name, this.address, this.locations, this.distance});

  factory Hub.fromJson(Map<String, dynamic> json) => _$HubFromJson(json);

  Map<String, dynamic> toJson() => _$HubToJson(this);
}

@JsonSerializable()
class HubAddress {
  final String? address;
  final double? latitude;
  final double? longitude;

  HubAddress({this.address, this.latitude, this.longitude});

  factory HubAddress.fromJson(Map<String, dynamic> json) =>
      _$HubAddressFromJson(json);

  Map<String, dynamic> toJson() => _$HubAddressToJson(this);
}

@JsonSerializable()
class HubLocations {
  final String? type;
  final List<List<List<double>>>? coordinates;

  HubLocations({this.type, this.coordinates});

  factory HubLocations.fromJson(Map<String, dynamic> json) =>
      _$HubLocationsFromJson(json);

  Map<String, dynamic> toJson() => _$HubLocationsToJson(this);
}
