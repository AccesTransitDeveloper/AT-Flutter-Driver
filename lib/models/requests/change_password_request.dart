class ChangePasswordRequest {
  final int? sendTo;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;
  final String? password;
  final String? verificationToken;

  ChangePasswordRequest({
    this.sendTo,
    this.countryPhoneCode,
    this.phone,
    this.email,
    this.password,
    this.verificationToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sendTo != null) map['sendTo'] = sendTo;
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (verificationToken != null) map['verificationToken'] = verificationToken;
    return map;
  }
}
