import 'package:json_annotation/json_annotation.dart';

part 'vehicle_color_response.g.dart';

@JsonSerializable()
class VehicleColorResponse {
  final List<VehicleColor>? colors;

  VehicleColorResponse({
    this.colors,
  });

  factory VehicleColorResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleColorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleColorResponseToJson(this);
}

@JsonSerializable()
class VehicleColor {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final bool? isActive;
  final int? uniqueId;

  VehicleColor({
    this.id,
    this.name,
    this.isActive,
    this.uniqueId,
  });

  factory VehicleColor.fromJson(Map<String, dynamic> json) =>
      _$VehicleColorFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleColorToJson(this);
}
