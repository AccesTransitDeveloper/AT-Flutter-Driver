class GenerateOtpRequest {
  final int? sendTo;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;

  GenerateOtpRequest({
    this.sendTo,
    this.countryPhoneCode,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sendTo != null) map['sendTo'] = sendTo;
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    return map;
  }
}
