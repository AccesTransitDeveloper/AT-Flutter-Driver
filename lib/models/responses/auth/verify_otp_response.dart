class VerifyOtpResponse {
  final String? message;
  final String? verificationToken;

  VerifyOtpResponse({
    this.message,
    this.verificationToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] as String?,
      verificationToken: json['verificationToken'] as String?,
    );
  }
}
