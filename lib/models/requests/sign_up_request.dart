class SignUpRequest {
  final int? authMethod;
  final String? firstName;
  final String? lastName;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;
  final String? countryCode;
  final String? creditCurrencyCode;
  final String? password;
  final String? referralCode;
  final String? socialId;
  // Driver-specific fields
  final String? countryId;
  final String? cityId;
  final String? drivingLicense;

  SignUpRequest({
    this.authMethod,
    this.firstName,
    this.lastName,
    this.countryPhoneCode,
    this.phone,
    this.email,
    this.countryCode,
    this.creditCurrencyCode,
    this.password,
    this.referralCode,
    this.socialId,
    this.countryId,
    this.cityId,
    this.drivingLicense,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (authMethod != null) map['authMethod'] = authMethod;
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (countryCode != null) map['countryCode'] = countryCode;
    if (creditCurrencyCode != null) map['creditCurrencyCode'] = creditCurrencyCode;
    if (password != null) map['password'] = password;
    if (referralCode != null) map['referralCode'] = referralCode;
    if (socialId != null) map['socialId'] = socialId;
    if (countryId != null) map['countryId'] = countryId;
    if (cityId != null) map['cityId'] = cityId;
    if (drivingLicense != null) map['drivingLicense'] = drivingLicense;
    return map;
  }
}
