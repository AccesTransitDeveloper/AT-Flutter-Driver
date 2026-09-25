import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/constants/app_constants.dart';
import 'payment_interface.dart' as payment;

/// Stripe payment manager implementation
class StripePaymentManager implements payment.PaymentInterface {
  payment.PaymentResultCallback? callback;
  String _publicKey = '';

  @override
  void initPaymentSdk(String publicKey) {
    _publicKey = publicKey;
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    debugPrint('StripePaymentManager - SDK initialized');
  }

  @override
  void createCardIntent({
    payment.CardDetails? card,
    payment.Intent? addCardIntentResponse,
    required payment.PaymentResultCallback callback,
  }) async {
    if (card != null && addCardIntentResponse != null) {
      card.clientSecret = addCardIntentResponse.clientSecret;
    }

    this.callback = callback;

    if (card == null || addCardIntentResponse == null) {
      callback.onPaymentError(Exception('Card details or intent response is null'));
      return;
    }

    try {
      // Parse expiry date (MM/YY format)
      int? expMonth;
      int? expYear;
      if (card.expiryDate != null && card.expiryDate!.contains('/')) {
        final parts = card.expiryDate!.split('/');
        if (parts.length == 2) {
          expMonth = int.tryParse(parts[0]);
          final yearPart = int.tryParse(parts[1]);
          if (yearPart != null) {
            expYear = yearPart < 100 ? 2000 + yearPart : yearPart;
          }
        }
      }

      // Set card details
      await Stripe.instance.dangerouslyUpdateCardDetails(
        CardDetails(
          number: card.cardNumber,
          expirationMonth: expMonth,
          expirationYear: expYear,
          cvc: card.cvv,
        ),
      );

      // Confirm setup intent
      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: card.clientSecret ?? '',
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: card.name,
            ),
          ),
        ),
      );

      final status = setupIntent.status;
      if (status == 'Succeeded' || status == 'succeeded') {
        callback.onCardMethodCreated(
          paymentMethodId: setupIntent.paymentMethodId,
          addCardIntentResponse: null,
        );
      } else if (status == 'RequiresPaymentMethod' ||
          status == 'requires_payment_method') {
        callback.onPaymentError(Exception(status));
      } else {
        callback.onCardMethodCreated(
          paymentMethodId: setupIntent.paymentMethodId,
          addCardIntentResponse: null,
        );
      }
    } catch (e) {
      debugPrint('StripePaymentManager - createCardIntent error: $e');
      callback.onPaymentError(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  void createPaymentIntent({
    payment.IntentPayment? intent,
    required payment.PaymentResultCallback callback,
  }) async {
    try {
      this.callback = callback;

      if (intent == null) {
        callback.onPaymentError(Exception('Intent is null'));
        return;
      }

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: intent.clientSecret ?? '',
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: intent.paymentMethod ?? '',
          ),
        ),
      );

      debugPrint(
          'StripePaymentManager - confirmPayment status: ${paymentIntent.status}');
      switch (paymentIntent.status) {
        case PaymentIntentsStatus.Succeeded:
          callback.onPaymentMethodCreated(
            paymentMethodId: paymentIntent.id,
            addCardIntentResponse: null,
          );
          break;

        case PaymentIntentsStatus.RequiresCapture:
          callback.onPaymentCapture();
          break;

        case PaymentIntentsStatus.RequiresPaymentMethod:
        case PaymentIntentsStatus.RequiresConfirmation:
        case PaymentIntentsStatus.RequiresAction:
        case PaymentIntentsStatus.Processing:
        case PaymentIntentsStatus.Canceled:
        case PaymentIntentsStatus.Unknown:
          callback.onPaymentError(Exception('Payment failed'));
          break;
      }
    } catch (e) {
      debugPrint('StripePaymentManager - createPaymentIntent error: $e');
      callback.onPaymentError(Exception('Payment failed'));
    }
  }

  /// Present payment sheet for collecting payment
  Future<void> presentPaymentSheet({
    required payment.IntentPayment intent,
    required payment.PaymentResultCallback callback,
  }) async {
    this.callback = callback;
    final stripePublicKey = _publicKey.isNotEmpty
        ? _publicKey
        : AppConstants.stripePublishableKey;
    Stripe.publishableKey = stripePublicKey;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'Accessible Transit',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      callback.onPaymentMethodCreated(
        paymentMethodId: null,
        addCardIntentResponse: intent,
      );
    } on StripeException catch (e) {
      debugPrint(
          'StripePaymentManager - presentPaymentSheet error: ${e.error.localizedMessage}');
      callback.onPaymentError(Exception(e.error.localizedMessage));
    } catch (e) {
      debugPrint('StripePaymentManager - presentPaymentSheet error: $e');
      callback.onPaymentError(e is Exception ? e : Exception('Payment failed'));
    }
  }
}
