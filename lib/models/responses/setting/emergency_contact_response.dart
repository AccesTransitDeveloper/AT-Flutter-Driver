import 'package:json_annotation/json_annotation.dart';

part 'emergency_contact_response.g.dart';

@JsonSerializable()
class EmergencyContactResponse {
  final List<EmergencyContact>? emergencyContacts;

  EmergencyContactResponse({this.emergencyContacts});

  factory EmergencyContactResponse.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactResponseToJson(this);
}

@JsonSerializable()
class EmergencyContact {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? phone;
  final String? countryPhoneCode;
  final String? image;

  EmergencyContact({
    this.id,
    this.name,
    this.phone,
    this.countryPhoneCode,
    this.image,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}
