import 'payment_interface.dart';

/// WebView-based payment manager for gateways that use web flow
/// (Razorpay, PayU, NestPay, etc.)
/// Passes intent back with null paymentMethodId to trigger WebView navigation.
class WebViewPaymentManager implements PaymentInterface {
  @override
  void initPaymentSdk(String publicKey) {
    // WebView-based flow, no SDK init needed
  }

  @override
  void createCardIntent({
    CardDetails? card,
    Intent? addCardIntentResponse,
    required PaymentResultCallback callback,
  }) {
    // Card addition not supported via WebView gateways
  }

  @override
  void createPaymentIntent({
    IntentPayment? intent,
    required PaymentResultCallback callback,
  }) {
    // Pass intent back with null paymentMethodId to trigger WebView navigation
    callback.onPaymentMethodCreated(
      paymentMethodId: null,
      addCardIntentResponse: intent,
    );
  }
}
