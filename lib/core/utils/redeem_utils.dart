import '../localization/app_strings.dart';
import '../../models/responses/redeem/redeem_point_response.dart';

/// Transaction type constants (matches Kotlin RewardPointTransactionType)
class RewardPointTransactionType {
  static const int referralBonus = 1;
  static const int bookingBonus = 2;
  static const int tipBonus = 3;
  static const int reviewBonus = 4;
  static const int dailyBookingAcceptedBonus = 5;
  static const int dailyBookingCompletedBonus = 6;
  static const int averageRatingBonus = 7;
  static const int rewardPointWithdraw = 8;
  static const int referralProfitBonus = 9;
  static const int awardProfitBonus = 10;
}

/// Status constants (matches Kotlin CreditStatus)
class RedeemPointStatus {
  static const int added = 1;
  static const int deducted = 2;
}

/// Get redeem description based on transaction type
String getRedeemDescription(RedeemTransaction transaction) {
  String description = '';

  switch (transaction.transactionType) {
    case RewardPointTransactionType.referralBonus:
      description = getString(
        appStr.descriptionReferralBonus,
        'description_referral_bonus',
      );
      break;

    case RewardPointTransactionType.bookingBonus:
      description = getString(
        appStr.descriptionBookingBonus,
        'description_booking_bonus',
      );
      if (transaction.bookingUniqueId != null && transaction.bookingUniqueId!.isNotEmpty) {
        description = '$description : ${transaction.bookingUniqueId}';
      }
      break;

    case RewardPointTransactionType.reviewBonus:
      description = getString(
        appStr.descriptionReviewBonus,
        'description_review_bonus',
      );
      if (transaction.bookingUniqueId != null && transaction.bookingUniqueId!.isNotEmpty) {
        description = '$description : ${transaction.bookingUniqueId}';
      }
      break;

    case RewardPointTransactionType.tipBonus:
      description = getString(
        appStr.descriptionTipBonus,
        'description_tip_bonus',
      );
      if (transaction.bookingUniqueId != null && transaction.bookingUniqueId!.isNotEmpty) {
        description = '$description : ${transaction.bookingUniqueId}';
      }
      break;

    case RewardPointTransactionType.dailyBookingAcceptedBonus:
      description = getString(
        appStr.descriptionDailyBookingAcceptedBonus,
        'description_daily_booking_accepted_bonus',
      );
      break;

    case RewardPointTransactionType.dailyBookingCompletedBonus:
      description = getString(
        appStr.descriptionDailyBookingCompletedBonus,
        'description_daily_booking_completed_bonus',
      );
      break;

    case RewardPointTransactionType.averageRatingBonus:
      description = getString(
        appStr.descriptionAverageRatingBonus,
        'description_average_rating_bonus',
      );
      break;

    case RewardPointTransactionType.rewardPointWithdraw:
      description = getString(
        appStr.descriptionRewardPointWithdraw,
        'description_reward_point_withdraw',
      );
      break;

    case RewardPointTransactionType.referralProfitBonus:
      description = getString(
        appStr.descriptionReferralProfitBonus,
        'description_referral_profit_bonus',
      );
      break;

    case RewardPointTransactionType.awardProfitBonus:
      description = getString(
        appStr.descriptionAwardProfitBonus,
        'description_award_profit_bonus',
      );
      break;

    default:
      description = transaction.description ?? '';
  }

  return description;
}
