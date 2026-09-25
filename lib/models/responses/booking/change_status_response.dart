import 'package:json_annotation/json_annotation.dart';

part 'change_status_response.g.dart';

@JsonSerializable()
class ChangeStatusResponse {
  final bool? isRemoveBooking;

  ChangeStatusResponse({this.isRemoveBooking});

  factory ChangeStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangeStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeStatusResponseToJson(this);
}
