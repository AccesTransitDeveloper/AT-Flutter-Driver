import 'package:json_annotation/json_annotation.dart';

part 'emergency_contact_request.g.dart';

@JsonSerializable()
class EmergencyContactRequest {
  final String? name;
  final String? phone;
  final String? countryPhoneCode;

  EmergencyContactRequest({this.name, this.phone, this.countryPhoneCode});

  factory EmergencyContactRequest.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactRequestToJson(this);
}
