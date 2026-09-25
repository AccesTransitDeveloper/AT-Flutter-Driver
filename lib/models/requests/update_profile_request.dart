import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateProfileRequest {
  final String? enteredOTP;
  final String? enteredOTPMail;
  final String? firstName;
  final String? lastName;
  final String? countryPhoneCode;
  final String? phone;
  final int? sendTo;
  final String? email;
  final String? password;
  final String? newPassword;
  final String? countryCode;
  final String? drivingLicense;

  UpdateProfileRequest({
    this.enteredOTP,
    this.enteredOTPMail,
    this.firstName,
    this.lastName,
    this.countryPhoneCode,
    this.phone,
    this.sendTo,
    this.email,
    this.password,
    this.newPassword,
    this.countryCode,
    this.drivingLicense,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
