class VerifyOtpRequest {
  final int? sendTo;
  final String? countryPhoneCode;
  final String? phone;
  final String? email;
  final String? enteredOTP;

  /// Email OTP. Native sends this alongside [enteredOTP] in a single call when
  /// both verifications are on (RegisterViewModel.verifyOtp) — without it the
  /// server only ever saw the phone code.
  final String? enteredOTPMail;

  VerifyOtpRequest({
    this.sendTo,
    this.countryPhoneCode,
    this.phone,
    this.email,
    this.enteredOTP,
    this.enteredOTPMail,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (sendTo != null) map['sendTo'] = sendTo;
    if (countryPhoneCode != null) map['countryPhoneCode'] = countryPhoneCode;
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    if (enteredOTP != null) map['enteredOTP'] = enteredOTP;
    if (enteredOTPMail != null) map['enteredOTPMail'] = enteredOTPMail;
    return map;
  }
}
