import '../constants/app_constants.dart';
import '../localization/app_strings.dart';
import '../../models/responses/payment/transaction_credit_response.dart';

/// Get wallet transaction description based on transaction type
String getWalletDescription(TransactionCredit transaction) {
  String description = '';

  switch (transaction.transactionType) {
    case CreditTransactionType.referralBonus:
      description = getString(appStr.descriptionReferralBonus, 'description_referral_bonus');

    case CreditTransactionType.referrerBonus:
      description = getString(appStr.descriptionReferrerBonus, 'description_referrer_bonus');

    case CreditTransactionType.digitalPayment:
      description = getString(appStr.descriptionDigitalPayment, 'description_digital_payment');
      final paymentMode = int.tryParse(transaction.description ?? '');
      if (paymentMode != null) {
        final modeName = PaymentGatewayType.fromValue(paymentMode)?.getName();
        if (modeName != null && modeName.isNotEmpty) {
          description = '$description: $modeName';
        }
      }

    case CreditTransactionType.fromAdmin:
      description = getString(appStr.descriptionAdmin, 'description_admin');

    case CreditTransactionType.tipPayment:
      description = getString(appStr.descriptionTipPayment, 'description_tip_payment');
      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        description = '$description : ${transaction.description}';
      }

    case CreditTransactionType.toFriend:
      description = getString(appStr.descriptionToFriend, 'description_to_friend');
      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        description = '$description : ${transaction.description}';
      }

    case CreditTransactionType.fromFriend:
      description = getString(appStr.descriptionFromFriend, 'description_from_friend');
      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        description = '$description : ${transaction.description}';
      }

    case CreditTransactionType.rewardPointWithdraw:
      description = getString(appStr.descriptionRewardPointWithdraw, 'description_reward_point_withdraw');

    case CreditTransactionType.penalty:
      final penaltyLabel = getString(appStr.descriptionPenalty, 'description_penalty');
      switch (transaction.description) {
        case PenaltyType.rideCancellation:
          description =
              '$penaltyLabel : ${getString(appStr.descriptionRideCancellation, 'description_ride_cancellation')}';
        case PenaltyType.lowRating:
          description =
              '$penaltyLabel : ${getString(appStr.descriptionLowRating, 'description_low_rating')}';
        case PenaltyType.missedRides:
          description =
              '$penaltyLabel : ${getString(appStr.descriptionMissedRides, 'description_missed_rides')}';
        default:
          description = penaltyLabel;
      }

    case CreditTransactionType.bookingPayment:
      description = getString(appStr.descriptionBookingPayment, 'description_booking_payment');
      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        description = '$description : ${transaction.description}';
      }

    case CreditTransactionType.cancelBookingPayment:
      description = getString(appStr.descriptionCancelBookingPayment, 'description_cancel_booking_payment');
      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        description = '$description : ${transaction.description}';
      }

    case CreditTransactionType.bookingProfit:
      description = getString(appStr.descriptionBookingProfit, 'description_booking_profit');

    case CreditTransactionType.incentive:
      description = getString(appStr.descriptionIncentive, 'description_incentive');

    case CreditTransactionType.bankTransfer:
      description = getString(appStr.descriptionBankTransfer, 'description_bank_transfer');

    case CreditTransactionType.refund:
      description = getString(appStr.descriptionRefund, 'description_refund');
      if (transaction.bookingUniqueId != null) {
        description = '$description: ${transaction.bookingUniqueId}';
      }
      if (transaction.description == 'BOOKING_REMAINING_AMOUNT') {
        final reason = getString(appStr.descriptionRefundReason, 'description_refund_reason');
        final bookingRemaining =
            getString(appStr.descriptionBookingRemainingAmount, 'description__booking_remaining_amount');
        description = '$description\n$reason: $bookingRemaining';
      } else if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        final reason = getString(appStr.descriptionRefundReason, 'description_refund_reason');
        description = '$description\n$reason: ${transaction.description}';
      }

    case CreditTransactionType.fixGroupBooking:
      description = getString(appStr.descriptionFixGroupBooking, 'description_fix_group_booking');

    case CreditTransactionType.subscription:
      description = getString(appStr.descriptionSubscription, 'description_subscription');
      final paymentMode = int.tryParse(transaction.description ?? '');
      if (paymentMode != null) {
        final modeName = PaymentGatewayType.fromValue(paymentMode)?.getName();
        if (modeName != null && modeName.isNotEmpty) {
          description = '$description: $modeName';
        }
      }

    default:
      description = transaction.description ?? '';
  }

  return description;
}
