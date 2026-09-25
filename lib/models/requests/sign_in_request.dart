class SignInRequest {
  final int? sendTo;
  final int? loginBy;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;
  final String? password;
  final String? enteredOTP;
  final String? socialId;
  final String? language;

  SignInRequest({
    this.sendTo,
    this.loginBy,
    this.countryPhoneCode,
    this.phone,
    this.email,
    this.password,
    this.enteredOTP,
    this.socialId,
    this.language,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sendTo != null) map['sendTo'] = sendTo;
    if (loginBy != null) map['loginBy'] = loginBy;
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (enteredOTP != null) map['enteredOTP'] = enteredOTP;
    if (socialId != null) map['socialId'] = socialId;
    if (language != null) map['language'] = language;
    return map;
  }
}
