class CheckRegisteredRequest {
  final int loginBy;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;
  final String? socialId;

  CheckRegisteredRequest({
    required this.loginBy,
    this.countryPhoneCode,
    this.phone,
    this.email,
    this.socialId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'loginBy': loginBy,
    };
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (socialId != null) map['socialId'] = socialId;
    return map;
  }
}
