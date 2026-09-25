import 'dart:convert';

/// Response model for payment webview callback
class PaymentWebViewResponse {
  final String? message;
  final bool? success;

  PaymentWebViewResponse({
    this.message,
    this.success,
  });

  factory PaymentWebViewResponse.fromJson(Map<String, dynamic> json) {
    return PaymentWebViewResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );
  }

  /// Parse JSON string to PaymentWebViewResponse
  /// Returns null if parsing fails
  static PaymentWebViewResponse? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PaymentWebViewResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'success': success,
      };
}
