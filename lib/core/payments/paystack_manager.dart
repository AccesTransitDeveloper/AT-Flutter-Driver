import 'payment_interface.dart';

/// Paystack payment manager (web-based)
class PaystackManager implements PaymentInterface {
  @override
  void initPaymentSdk(String publicKey) {
    // Paystack uses web-based flow, no SDK init needed
  }

  @override
  void createCardIntent({
    CardDetails? card,
    Intent? addCardIntentResponse,
    required PaymentResultCallback callback,
  }) {
    // Paystack card addition handled via WebView
    callback.onPaymentError(Exception('Use WebView for Paystack'));
  }

  @override
  void createPaymentIntent({
    IntentPayment? intent,
    required PaymentResultCallback callback,
  }) {
    // Paystack payment handled via WebView
    callback.onPaymentError(Exception('Use WebView for Paystack'));
  }
}
