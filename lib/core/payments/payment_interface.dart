import '../../models/responses/payment/add_card_intent_response.dart';
import '../../models/responses/payment/payment_intent_response.dart';

export '../../models/responses/payment/add_card_intent_response.dart'
    show Intent;
export '../../models/responses/payment/payment_intent_response.dart'
    show IntentPayment;

/// Payment SDK interface
abstract class PaymentInterface {
  void initPaymentSdk(String publicKey);

  void createCardIntent({
    CardDetails? card,
    Intent? addCardIntentResponse,
    required PaymentResultCallback callback,
  });

  void createPaymentIntent({
    IntentPayment? intent,
    required PaymentResultCallback callback,
  });
}

/// Payment result callback interface
abstract class PaymentResultCallback {
  void onPaymentMethodCreated({
    String? paymentMethodId,
    IntentPayment? addCardIntentResponse,
  });

  void onPaymentCapture();

  void onCardMethodCreated({
    String? paymentMethodId,
    Intent? addCardIntentResponse,
  });

  void onPaymentError(Exception error);
}

/// Card details model
class CardDetails {
  String? name;
  String? cardNumber;
  String? expiryDate;
  String? cvv;
  String? clientSecret;

  CardDetails({
    this.name,
    this.cardNumber,
    this.expiryDate,
    this.cvv,
    this.clientSecret,
  });
}

/// Payment callback implementation
class PaymentCallbackImpl implements PaymentResultCallback {
  final void Function(String? paymentMethodId, IntentPayment? intentResponse)
      _onSuccess;
  final void Function() _onCapture;
  final void Function(String? paymentMethodId, Intent? intent) _onCardCreated;
  final void Function(Exception error) _onError;

  PaymentCallbackImpl({
    required void Function(String? paymentMethodId, IntentPayment? intentResponse)
        onSuccess,
    required void Function() onCapture,
    required void Function(String? paymentMethodId, Intent? intent) onCardCreated,
    required void Function(Exception error) onError,
  })  : _onSuccess = onSuccess,
        _onCapture = onCapture,
        _onCardCreated = onCardCreated,
        _onError = onError;

  @override
  void onPaymentMethodCreated({
    String? paymentMethodId,
    IntentPayment? addCardIntentResponse,
  }) {
    _onSuccess(paymentMethodId, addCardIntentResponse);
  }

  @override
  void onPaymentCapture() {
    _onCapture();
  }

  @override
  void onCardMethodCreated({
    String? paymentMethodId,
    Intent? addCardIntentResponse,
  }) {
    _onCardCreated(paymentMethodId, addCardIntentResponse);
  }

  @override
  void onPaymentError(Exception error) {
    _onError(error);
  }
}
