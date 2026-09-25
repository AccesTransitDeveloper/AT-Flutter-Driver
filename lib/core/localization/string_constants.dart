/// Placeholder constants for string replacement
class StringConstant {
  static const String appName = '_APP_NAME';
  static const String value = '_VALUE';
  static const String param = '_PARAM';
  static const String leftParam = '_LEFT_PARAM';
  static const String rightParam = '_RIGHT_PARAM';
  static const String terms = '_TERMS';
  static const String privacy = '_PRIVACY';
  static const String referralCode = '_REFERRAL_CODE';
  static const String supportId = '_SUPPORT_ID';
  static const String unitValue = '_UNIT_VALUE';
  static const String unit = '_UNIT';
  static const String cardNumber = '_CARD_NUMBER';
  static const String zoneName = '_ZONE_NAME';
  static const String number = '_NUMBER';
  static const String minimumRedeemPoint = '_MINIMUM_REDEEM_POINT';
  static const String driverTimeEstimate = '_DRIVER_TIME_ESTIMATE';
  static const String redeemPoints = '_REDEEM_POINTS';
  static const String bookingNo = '_BOOKING_NO';
  static const String amount = '_AMOUNT';
}

/// Extension to replace placeholders in strings
extension StringPlaceholders on String {
  /// Replace placeholders like {{_VALUE}} with actual values
  /// Usage: "Hello {{_NAME}}".replacePlaceholders({'_NAME': 'John'})
  String replacePlaceholders(Map<String, dynamic> replacements) {
    String result = this;
    replacements.forEach((placeholder, value) {
      result = result.replaceAll('{{$placeholder}}', value.toString());
    });
    return result;
  }
}
