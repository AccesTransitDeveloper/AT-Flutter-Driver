import 'package:json_annotation/json_annotation.dart';

part 'business_type_response.g.dart';

@JsonSerializable()
class BusinessTypeResponse {
  final List<int>? businessTypes;
  final List<int>? bookingTypes;

  BusinessTypeResponse({this.businessTypes, this.bookingTypes});

  factory BusinessTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessTypeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessTypeResponseToJson(this);
}
