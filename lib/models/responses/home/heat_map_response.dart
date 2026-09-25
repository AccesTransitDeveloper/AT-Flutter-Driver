import 'package:json_annotation/json_annotation.dart';

part 'heat_map_response.g.dart';

@JsonSerializable()
class HeatMapResponse {
  final List<HeatMapLocation>? locations;
  final int? mapZoomLevel;

  HeatMapResponse({
    this.locations,
    this.mapZoomLevel,
  });

  factory HeatMapResponse.fromJson(Map<String, dynamic> json) =>
      _$HeatMapResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HeatMapResponseToJson(this);
}

@JsonSerializable()
class HeatMapLocation {
  final double? latitude;
  final double? longitude;
  @JsonKey(defaultValue: 1.0)
  final double weight;

  HeatMapLocation({
    this.latitude,
    this.longitude,
    this.weight = 1.0,
  });

  factory HeatMapLocation.fromJson(Map<String, dynamic> json) =>
      _$HeatMapLocationFromJson(json);

  Map<String, dynamic> toJson() => _$HeatMapLocationToJson(this);
}
