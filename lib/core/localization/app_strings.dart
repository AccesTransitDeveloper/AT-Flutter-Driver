import 'dart:convert';

import '../../models/string_object.dart';
import '../constants/app_constants.dart';
import 'local_strings.dart';

/// Global singleton for API strings (like appStr in Kotlin)
AppStrings appStr = AppStrings();

/// Current business type for string resolution (like businessTypeForString in Kotlin)
int businessTypeForString = BusinessType.taxi;

/// Holds all string values from API
class AppStrings {
  // App
  dynamic appName;

  // Buttons
  dynamic buttonNext;
  dynamic buttonContinue;
  dynamic buttonCancel;
  dynamic buttonSave;
  dynamic buttonDone;
  dynamic buttonUpdate;
  dynamic buttonSubmit;
  dynamic buttonConfirm;
  dynamic buttonOk;
  dynamic buttonAccept;
  dynamic buttonReject;
  dynamic buttonClose;
  dynamic buttonLogout;
  dynamic buttonContactUs;
  dynamic buttonYes;
  dynamic buttonKeepMyTrip;
  dynamic buttonCallUser;
  dynamic buttonCallSupport;
  dynamic buttonVerifyCode;
  dynamic buttonSubmitInvoice;
  dynamic buttonViewReceipt;
  dynamic buttonContinueWithGoogle;
  dynamic buttonContinueWithApple;
  dynamic buttonContinueWithEmail;
  dynamic buttonContinueWithPhone;
  dynamic buttonUseMobileNumber;
  dynamic buttonUseEmailInstead;
  dynamic buttonResendPhoneOtp;
  dynamic buttonResendEmailOtp;
  dynamic buttonIAgree;
  dynamic buttonChangeMobileNumber;
  dynamic buttonChangeEmailAddress;
  dynamic buttonLoginWithPassword;
  dynamic buttonForgotPassword;
  dynamic buttonLoginWithOtp;
  dynamic buttonApplyFilter;

  // Hints
  dynamic hintPhoneNumber;
  dynamic hintDrivingLicense;
  dynamic hintVehicleLicense;
  dynamic headingCheckr;
  dynamic descriptionBackgroundVerification;
  dynamic descriptionCheckrInProgress;
  dynamic descriptionCheckrPending;
  dynamic descriptionCheckrVerified;
  dynamic descriptionCheckrReviewRequired;
  dynamic descriptionDrivingLicense;
  dynamic hintFirstName;
  dynamic hintLastName;
  dynamic hintEmailExample;
  dynamic hintPassword;
  dynamic hintEnterPassword;
  dynamic hintConfirmPassword;
  dynamic hintEnterReferralCode;
  dynamic hintSearch;
  dynamic hintMessage;
  dynamic hintSubject;
  dynamic hintWriteSpecificReason;
  dynamic hintEnterConfirmationCode;

  // Headings
  dynamic headingEnterYourMobileNumber;
  dynamic headingEnterYourEmail;
  dynamic headingWhatIsYourName;
  dynamic headingAcceptTerms;
  dynamic headingHaveReferralCode;
  dynamic headingVerifyAccount;
  dynamic headingCreatePassword;
  dynamic headingResetPassword;
  dynamic headingProfile;
  dynamic headingDocument;
  dynamic headingInbox;
  dynamic headingReferral;
  dynamic headingSetting;
  dynamic headingSettings;
  dynamic headingContactUs;
  dynamic headingWallet;
  dynamic headingActivity;
  dynamic headingUpcoming;
  dynamic headingPast;
  dynamic headingOpportunities;
  dynamic buttonIncentives;
  dynamic buttonPenalties;
  dynamic headingMarketplaceRide;
  dynamic errorNoBookingsFound;
  dynamic headingEarnings;
  dynamic headingLogout;
  dynamic headingCancelTrip;
  dynamic headingWhyDoYouWantToCancel;
  dynamic headingCallUserSupport;
  dynamic headingConfirmation;
  dynamic headingConfirmationCode;
  dynamic headingInvoice;
  dynamic headingTripDetails;
  dynamic headingCustomerDetails;
  dynamic headingHelpAndSafety;
  dynamic headingCancelBooking;
  dynamic headingAbn;
  dynamic headingAccount;
  dynamic headingAdditionalTerms;
  dynamic headingApplicationForm;
  dynamic headingAssessment;
  dynamic headingEnterVehicleInfo;
  dynamic headingLearningCenter;
  dynamic headingManageAccount;
  dynamic headingPayment;
  dynamic headingPoliceCheck;
  dynamic headingPrivacy;
  dynamic headingSelectBusiness;
  dynamic headingVehicles;
  dynamic headingWorkHub;

  // Buttons (trip detail)
  dynamic buttonCancelBooking;
  dynamic buttonGoBack;
  dynamic buttonGetHelp;

  // Descriptions
  dynamic descriptionTermsOfUse;
  dynamic descriptionPrivacyNotice;
  dynamic descriptionAgreeTermsPrivacy;
  dynamic descriptionEmail;
  dynamic descriptionPhone;
  dynamic descriptionPassword;
  dynamic descriptionMale;
  dynamic descriptionFemale;
  dynamic descriptionNotSet;
  dynamic descriptionPending;
  dynamic descriptionUploaded;
  dynamic descriptionAccepted;
  dynamic descriptionRejected;
  dynamic descriptionCancelled;
  dynamic descriptionCancelTrip;
  dynamic descriptionCancellationChargeWillBeApplied;
  dynamic descriptionOthers;
  dynamic descriptionStatusAlertComing;
  dynamic descriptionStatusAlertArrived;
  dynamic descriptionStatusAlertStart;
  dynamic descriptionStatusAlertStopHere;
  dynamic descriptionStatusAlertEnd;
  dynamic descriptionStatusAlertPickedCourier;
  dynamic descriptionStatusAlertDroppedCourier;
  dynamic descriptionEarning;
  dynamic descriptionRideWithCustomer;
  dynamic descriptionReasonPrefix;
  dynamic descriptionSelectReasonForCancellation;
  dynamic descriptionEstimatedPrice;
  dynamic descriptionPaymentMode;
  dynamic descriptionInvoiceCollectCash;
  dynamic descriptionFrom;
  dynamic descriptionTo;
  dynamic descriptionNoDataFound;
  dynamic descriptionHome;
  dynamic descriptionWork;
  dynamic descriptionLanguage;
  dynamic descriptionLightMode;
  dynamic descriptionDarkMode;
  dynamic descriptionSystemDefault;
  dynamic descriptionLogout;
  dynamic descriptionAppVersion;
  dynamic descriptionToday;
  dynamic descriptionTomorrow;
  dynamic descriptionYesterday;
  dynamic descriptionDistance;
  dynamic descriptionDuration;
  dynamic descriptionPickup;
  dynamic descriptionDropOff;
  dynamic descriptionDestination;
  dynamic descriptionPayment;
  dynamic descriptionCash;
  dynamic descriptionWallet;
  dynamic descriptionStripe;
  dynamic descriptionPaystack;
  dynamic descriptionRazorpay;
  dynamic descriptionMercadoPago;
  dynamic descriptionPayu;
  dynamic descriptionPago;
  dynamic descriptionZaincash;
  dynamic descriptionHyperpay;
  dynamic descriptionNestpay;
  dynamic descriptionQicard;
  dynamic descriptionMpesa;
  dynamic descriptionDistanceUnitKm;
  dynamic descriptionDistanceUnitMi;
  dynamic descriptionMinutesUnit;
  dynamic descriptionHoursUnit;
  dynamic descriptionChat;
  dynamic descriptionNoMessagesYet;
  dynamic descriptionFailedToLoadImage;
  dynamic descriptionAdmin;
  dynamic descriptionBankPending;
  dynamic descriptionBankProcessing;
  dynamic descriptionBankTransfer;
  dynamic descriptionBankVerified;
  dynamic descriptionBookingPayment;
  dynamic descriptionBookingProfit;
  dynamic descriptionCancelBookingPayment;
  dynamic descriptionCurrentMonth;
  dynamic descriptionDigitalPayment;
  dynamic descriptionFromFriend;
  dynamic descriptionLast7Days;
  dynamic descriptionLowRating;
  dynamic descriptionMissedRides;
  dynamic descriptionNoPastBookingsFound;
  dynamic descriptionNoUpcomingBookings;
  dynamic descriptionNoUpcomingBookingsSub;
  dynamic descriptionPrevious6Months;
  dynamic descriptionPreviousMonth;
  dynamic descriptionReferrerBonus;
  dynamic descriptionRefund;
  dynamic descriptionRefundReason;
  dynamic descriptionBookingRemainingAmount;
  dynamic descriptionRideCancellation;
  dynamic descriptionSpecificDates;
  dynamic descriptionSubscription;
  dynamic descriptionTipPayment;
  dynamic descriptionToFriend;
  dynamic descriptionTaxi;
  dynamic descriptionDelivery;
  dynamic descriptionCourier;

  // Errors
  dynamic errorPleaseEnterPhoneNumber;
  dynamic errorPleaseEnterValidPhoneNumber;
  dynamic errorPleaseEnterEmail;
  dynamic errorPleaseEnterValidEmail;
  dynamic errorPleaseEnterPassword;
  dynamic errorPleaseEnterOtp;
  dynamic errorPleaseEnterRedeemPoint;
  dynamic errorPleaseValidRedeemPoint;
  dynamic errorEnterValidRedeemPoint;
  dynamic errorSocialLoginFailed;
  dynamic errorPleaseAcceptTerms;
  dynamic errorInvalidReferralCode;
  dynamic errorPasswordConfirmMismatch;
  dynamic errorPleaseEnterValidFirstName;
  dynamic errorPleaseAddLicense;
  dynamic errorPleaseEnterVehicleLicense;
  dynamic errorPleaseEnterValidLastName;
  dynamic errorAmountIsMoreThanWithdrawLimit;
  dynamic errorLocationNotAvailable;
  dynamic errorNoHubFound;
  dynamic errorNoTermsAvailable;
  dynamic errorPdfLoadFailed;
  dynamic errorPleaseAcceptAdditionalTerms;
  dynamic errorPleaseCompleteAssessment;
  dynamic errorPleaseDownloadApplicationForm;
  dynamic errorPleaseEnterCardName;
  dynamic errorPleaseEnterValidAmount;
  dynamic errorPleaseEnterValidCardNumber;
  dynamic errorPleaseEnterValidCvv;
  dynamic errorPleaseEnterValidExpiryDate;
  dynamic errorPleaseEnterWalletAmount;
  dynamic errorPleaseSelectBusiness;
  dynamic errorPleaseSelectCard;
  dynamic errorPleaseSubmitAbn;
  dynamic errorPleaseSubmitPoliceCheck;

  // Booking Status
  dynamic bookingStatusRequested;
  dynamic descriptionDriverAccepted;
  dynamic bookingStatusInRoute;
  dynamic bookingStatusArrivedAtPickup;
  dynamic bookingStatusStarted;

  // Booking Screen
  dynamic descriptionCompletedTrips;
  dynamic descriptionTime;
  dynamic descriptionWaitingTime;
  dynamic descriptionStopWaitingTime;
  dynamic descriptionTrafficTime;
  dynamic descriptionTotalDistance;
  dynamic descriptionTotalTime;
  dynamic headingYouWillEarn;
  dynamic descriptionYouWillEarnByAcceptingTheBooking;
  dynamic buttonComing;
  dynamic buttonArrivedAtPickUp;
  dynamic buttonTapWhenYouStart;
  dynamic buttonTapWhenYouArrivedAtStop;
  dynamic buttonSwipeToPickOrder;
  dynamic buttonDropOrder;
  dynamic buttonTapTwiceEndBooking;
  dynamic buttonMoveBooking;
  dynamic buttonSwitchBooking;
  dynamic headingSwitchBooking;
  dynamic hintTypeAnythingHere;
  dynamic descriptionPlatformProfitValue;

  // Ride Types
  dynamic descriptionNormal;
  dynamic descriptionShare;
  dynamic descriptionRental;
  dynamic descriptionFixGroupBooking;

  // Missing Information
  dynamic subHeadingMissingInformation;
  dynamic errorPleaseEnterConfirmationCode;
  dynamic errorPleaseUpdateProfile;
  dynamic errorPleaseUpdateMandatoryDocument;
  dynamic errorNotApprovedYet;
  dynamic descriptionYourAccountIsDeclined;
  dynamic descriptionYourAccountIsBlocked;
  dynamic descriptionByContinuingYouAgree;
  dynamic hintCountry;
  dynamic hintCity;
  dynamic headingCountries;
  dynamic headingCities;
  dynamic hintSearchCountry;
  dynamic hintSearchCity;
  dynamic textSelectCountry;
  dynamic textSelectCity;
  dynamic errorPleaseUpdateCountry;
  dynamic errorPleaseUpdateCity;
  dynamic errorPleaseAddVehicle;
  dynamic errorPleaseUpdateMandatoryVehicleDocument;
  dynamic subHeadingVehicleDocument;
  dynamic headingAvailability;
  dynamic errorNoAvailabilityAdded;
  dynamic errorAdminReviewYourProfile;
  dynamic errorAdminDocRejected;
  dynamic errorAdminDocExpired;
  dynamic errorAdminVehicleRejected;
  dynamic errorAdminVehicleDocRejected;
  dynamic errorAdminVehicleDocExpired;
  dynamic textRequiredActions;
  dynamic textGoOnlineWhenResolved;
  dynamic textPleaseContactSupport;

  // Home Screen
  dynamic textYoureOffline;
  dynamic textYoureOnline;
  dynamic buttonGo;
  dynamic buttonPickVehicle;
  dynamic buttonDropVehicle;
  dynamic errorWalletLimitCash;

  // Profile Screen
  dynamic headingName;
  dynamic headingDriverInfo;
  dynamic descriptionUniqueId;
  dynamic descriptionRating;
  dynamic descriptionVehicleStatus;
  dynamic descriptionVehicleAdded;
  dynamic descriptionVehicleNotAdded;
  dynamic descriptionDocumentStatus;
  dynamic descriptionUploadProfile;
  dynamic descriptionCamera;
  dynamic descriptionImage;
  dynamic descriptionProfileName;
  dynamic descriptionProfileEmail;
  dynamic descriptionYouWillUseThisNumber;
  dynamic descriptionYouWillUseThisEmail;
  dynamic descriptionVerificationCodeSendToNumber;
  dynamic descriptionEnterOtpSentTo;
  dynamic descriptionResendPhoneCode;
  dynamic descriptionResendEmailCode;
  dynamic descriptionProfilePicPending;
  dynamic descriptionProfilePicAccepted;
  dynamic descriptionProfilePicRejected;
  dynamic descriptionProfilePicUploaded;

  // Document Screen
  dynamic subHeadingAdd;
  dynamic subHeadingEdit;
  dynamic hintDocumentId;
  dynamic hintUniqueId;
  dynamic hintExpiryDate;
  dynamic descriptionUploadDocument;
  dynamic descriptionPdf;
  dynamic errorNoDocumentFound;
  dynamic errorPleaseDocumentId;
  dynamic errorPleaseExpiryDate;
  dynamic errorPleaseSelectImage;
  dynamic errorPleaseUpdateDocument;
  dynamic successDocumentUpdated;
  dynamic errorDocumentUpdateFailed;
  dynamic headingSelectDate;
  dynamic headingSelectPhoneCode;

  // Earning Screen
  dynamic descriptionTodaysEarning;
  dynamic descriptionNetEarning;
  dynamic descriptionCashOnHand;
  dynamic descriptionCompletedRides;
  dynamic descriptionIncentive;
  dynamic descriptionCancelledRides;
  dynamic descriptionPenalty;
  dynamic descriptionCancelledByOther;
  dynamic descriptionOnlineTime;
  dynamic headingBookings;
  dynamic descriptionNoEarningsFound;
  dynamic buttonSelectDateRange;
  dynamic subHeadingEarningStatistics;
  dynamic descriptionEarningTotalEarning;
  dynamic descriptionEarningCompletedRides;
  dynamic descriptionTotalCancelledBooking;
  dynamic descriptionDeduction;
  dynamic buttonViewDetails;

  // Help / Contact Us / Support Tickets
  dynamic headingHelp;
  dynamic headingSubscription;

  // Subscription
  dynamic descriptionActiveSubscriptions;
  dynamic descriptionAvailableSubscriptions;
  dynamic descriptionFreeTrial;
  dynamic descriptionValueDays;
  dynamic descriptionValueFreeTrial;
  dynamic descriptionLifeTimePlan;
  dynamic descriptionBenefits;
  dynamic descriptionPaymentPending;
  dynamic descriptionExpiresSoon;
  dynamic descriptionExpiresInDays;
  dynamic descriptionCancelSubscription;
  dynamic descriptionUpgradeSubscription;
  dynamic descriptionMarketplaceAccess;
  dynamic descriptionApplyIncentive;
  dynamic descriptionApplyReward;
  dynamic descriptionMaxBookingsPerDay;
  dynamic descriptionMaxBiddingBookings;
  dynamic headingBiddingRequest;
  dynamic descriptionBiddingPrice;
  dynamic buttonAcceptBid;
  dynamic headingBiddingAmount;
  dynamic hintEnterBidAmount;
  dynamic errorDriverMaxBid;
  dynamic descriptionMaxScheduledRides;
  dynamic descriptionMaxCancelledBookings;
  dynamic descriptionMaxExtraBookings;
  dynamic descriptionMaxDailyRevenue;
  dynamic descriptionMaxTotalRevenue;
  dynamic descriptionMinWalletBalance;
  dynamic buttonRenew;
  dynamic buttonUpgrade;
  dynamic buttonSubscribe;
  dynamic subHeadingActiveSubscription;
  dynamic subHeadingSubscription;
  dynamic buttonPurchaseSubscription;
  dynamic buttonYesSure;
  dynamic descriptionActionSubscription;
  dynamic buttonViewBenefits;
  dynamic buttonGoToSubscription;
  dynamic descriptionSubscriptionInfo;
  dynamic descriptionAdminProfit;
  dynamic descriptionMaximumDailyBookingsReceived;
  dynamic descriptionMaximumCancelledBookingsAfterAccept;
  dynamic descriptionMaximumDailyScheduledRides;
  dynamic errorNoRecordFound;
  dynamic errorPleaseSelectSubscription;

  dynamic headingTermsAndConditions;
  dynamic headingRedeem;
  dynamic headingRedeemPoints;
  dynamic buttonRedeem;
  dynamic hintEnterPoints;
  dynamic descriptionAvailablePoints;
  dynamic descriptionEquivalent;
  dynamic descriptionAvailablePointsValue;
  dynamic descriptionBalance;
  dynamic errorNoRedeemHistoryFound;
  dynamic descriptionReferralBonus;
  dynamic descriptionBookingBonus;
  dynamic descriptionReviewBonus;
  dynamic descriptionTipBonus;
  dynamic descriptionDailyBookingAcceptedBonus;
  dynamic descriptionDailyBookingCompletedBonus;
  dynamic descriptionAverageRatingBonus;
  dynamic descriptionRewardPointWithdraw;
  dynamic descriptionRewardPointsValue;
  dynamic descriptionReferralProfitBonus;
  dynamic descriptionAwardProfitBonus;
  dynamic descriptionThankYouForChoosing;
  dynamic buttonEmail;
  dynamic buttonCall;
  dynamic buttonRaiseNewTicket;
  dynamic descriptionNoTicketsFound;
  dynamic headingRaiseNewTicket;
  dynamic headingTicketDetail;
  dynamic headingChatWithAppName;
  dynamic descriptionSelectCategory;
  dynamic buttonCloseTicket;
  dynamic buttonReopenTicket;
  dynamic descriptionTicketOpen;
  dynamic descriptionTicketClosed;
  dynamic descriptionTicketReopen;
  dynamic descriptionTicketCancelled;
  dynamic descriptionSupportTicketId;
  dynamic descriptionBookingId;
  dynamic errorPleaseSelectTicketCategory;
  dynamic errorPleaseEnterSubject;
  dynamic errorPleaseSelectEnterMessage;

  // Settings Screen
  dynamic headingAppearance;
  dynamic descriptionSelectTheme;
  dynamic descriptionHeatMap;
  dynamic descriptionNavigationMap;
  dynamic descriptionInAppGoogle;
  dynamic descriptionGoogleMap;
  dynamic descriptionWazeMap;
  dynamic headingDeleteAccount;
  dynamic descriptionDeleteAccount;
  dynamic headingVerifyIdentity;
  dynamic descriptionSelectVerificationMethod;
  dynamic headingVerifyPassword;
  dynamic descriptionEnterPasswordFor;
  dynamic descriptionEnterPasswordToDelete;
  dynamic headingVerifyOtp;
  dynamic descriptionOtpSentTo;
  dynamic hintEnterOtp;
  dynamic buttonResendOtp;
  dynamic buttonVerify;
  dynamic headingSelectLanguage;
  dynamic descriptionDelete;
  dynamic descriptionSpeakingLanguage;
  dynamic descriptionSelectVerbalLanguage;
  dynamic headingEmergencyContacts;
  dynamic buttonAddContact;
  dynamic headingAddEmergencyContact;
  dynamic errorPleaseEnterContactName;
  dynamic descriptionNoEmergencyContacts;
  dynamic descriptionSureCallSos;
  dynamic descriptionSettingsGoingHome;
  dynamic descriptionSettingsGoingHomeDescription;
  dynamic descriptionAddAddress;
  dynamic hintSearchLocation;
  dynamic buttonSetLocationOnMap;
  dynamic descriptionGettingAddress;
  dynamic descriptionMoveMapToSelect;

  // Payment / Wallet Screen
  dynamic headingPayments;
  dynamic headingWalletHistory;
  dynamic buttonTransferMoney;
  dynamic buttonAdd;
  dynamic buttonAddNewCard;
  dynamic buttonSend;
  dynamic subHeadingPaymentMethods;
  dynamic headingAddWalletAmount;
  dynamic hintEnterAmount;
  dynamic headingAddCardDetails;
  dynamic hintCardHolderName;
  dynamic hintCardNumber;
  dynamic hintCvv;
  dynamic headingDeleteCard;
  dynamic descriptionDeleteCardMessage;
  dynamic headingSelectPaymentGateway;
  dynamic headingSendMoney;
  dynamic hintNumberExample;
  dynamic hintEnterTransferAmount;
  dynamic descriptionCustomer;
  dynamic descriptionDriver;
  dynamic descriptionZoneQueueNo;
  dynamic errorNoWalletHistoryFound;
  dynamic descriptionTransactionId;
  dynamic errorUserNotFound;
  dynamic subHeadingBankAccounts;
  dynamic buttonAddNewBank;
  dynamic headingDeleteBank;
  dynamic descriptionDeleteBank;
  dynamic descriptionBank;
  dynamic descriptionDebitAmount;
  dynamic descriptionTaxAmount;
  dynamic descriptionBankAmount;
  dynamic headingTransferOptions;
  dynamic headingBankTransfer;
  dynamic buttonSendToBank;
  dynamic hintEnterBankTransferAmount;
  dynamic descriptionTaxBreakdown;
  dynamic descriptionCard;

  // Receipt Screen
  dynamic headingReceipt;
  dynamic descriptionThanksForRiding;
  dynamic descriptionThanksForRidingNoName;
  dynamic descriptionTotal;
  dynamic descriptionSubtotal;
  dynamic descriptionFree;
  dynamic descriptionMinimumFareApplied;
  dynamic descriptionNoInvoiceData;
  dynamic descriptionReceiptDisclaimer;

  // Feedback Screen
  dynamic headingFeedback;
  dynamic subHeadingRateYourRideExperience;
  dynamic subHeadingComment;
  dynamic hintWriteYourRideExperience;
  dynamic buttonMaybeLater;
  dynamic descriptionRateAwful;
  dynamic descriptionRateSad;
  dynamic descriptionRateGood;
  dynamic descriptionRateVeryGood;
  dynamic descriptionRateExcellent;
  dynamic descriptionRated;
  dynamic descriptionNotYetRated;

  // Vehicle Screen
  dynamic headingAddVehicle;
  dynamic headingEditVehicle;
  dynamic headingOtherVehicles;
  dynamic headingVehicleType;
  dynamic headingProvidingAccessibility;
  dynamic headingFallbackVehicles;
  dynamic descriptionEv;
  dynamic descriptionSelectYear;
  dynamic descriptionSelectBrand;
  dynamic descriptionSelectModel;
  dynamic descriptionVehicleName;
  dynamic descriptionPlateNo;
  dynamic descriptionVehicleColor;
  dynamic descriptionVehicleYear;
  dynamic descriptionBrand;
  dynamic descriptionModel;
  dynamic descriptionVehicleInfoExpiresSoon;
  dynamic descriptionVehiclePending;
  dynamic descriptionVehicleRejected;
  dynamic descriptionVehicleDraft;
  dynamic descriptionVehicleChangeAlertTitle;
  dynamic descriptionInvoiceBookingFeeUnit;
  dynamic descriptionDistanceCharge;
  dynamic descriptionTimeCharge;
  dynamic descriptionExpired;
  dynamic buttonAddVehicle;
  dynamic buttonManageVehicles;
  dynamic buttonPick;
  dynamic buttonDrop;
  dynamic errorPleaseEnterVehicleName;
  dynamic errorPleaseEnterVehicleColor;
  dynamic errorPleaseEnterVehiclePlateNo;
  dynamic errorPleaseSelectVehicleYear;
  dynamic errorPleaseSelectVehicleBrand;
  dynamic errorPleaseSelectVehicleModel;
  dynamic errorPleaseUpdateVehicle;
  dynamic errorPleaseSelectBrandFirst;
  dynamic headingConfirmVehicleChange;
  dynamic descriptionConfirmVehicleChange;
  dynamic descriptionNoVehiclesFound;
  dynamic headingQrCode;
  dynamic descriptionScanQrToPick;
  dynamic descriptionNoResults;
  dynamic errorNoCountriesFound;
  dynamic errorNoCitiesFound;

  // Referral Screen
  dynamic descriptionReferralList;
  dynamic descriptionInviteYourFriendAndEarnMoney;
  dynamic buttonViewReferralPolicy;
  dynamic descriptionYourReferralCode;
  dynamic descriptionTapToCopy;
  dynamic buttonReferYourFriend;
  dynamic successReferralCodeCopied;
  dynamic descriptionShareReferralCode;
  dynamic headingReferralPolicy;

  // Permission
  dynamic headingPermissionRequired;
  dynamic descriptionEnablePermissionInSettings;
  dynamic buttonOpenSettings;

  // Settings
  dynamic descriptionContactUpdated;
  dynamic descriptionContactAdded;
  dynamic descriptionContactRemoved;
  dynamic errorPleaseSelectOption;

  /// Update strings from API JSON response
  void updateFromJson(Map<String, dynamic> json) {
    appName = json['app_name'];

    // Buttons
    buttonNext = json['button_next'];
    buttonContinue = json['button_continue'];
    buttonCancel = json['button_cancel'];
    buttonSave = json['button_save'];
    buttonDone = json['button_done'];
    buttonUpdate = json['button_update'];
    buttonSubmit = json['button_submit'];
    buttonConfirm = json['button_confirm'];
    buttonOk = json['button_ok'];
    buttonAccept = json['button_accept'];
    buttonReject = json['button_reject'];
    buttonClose = json['button_close'];
    buttonLogout = json['button_logout'];
    buttonContactUs = json['button_contact_us'];
    buttonYes = json['button_yes'];
    buttonKeepMyTrip = json['button_keep_my_trip'];
    buttonCallUser = json['button_call_user'];
    buttonCallSupport = json['button_call_support'];
    buttonVerifyCode = json['button_verify_code'];
    buttonSubmitInvoice = json['button_submit_invoice'];
    buttonViewReceipt = json['button_view_receipt'];
    buttonContinueWithGoogle = json['button_continue_with_google'];
    buttonContinueWithApple = json['button_continue_with_apple'];
    buttonContinueWithEmail = json['button_continue_with_email'];
    buttonContinueWithPhone = json['button_continue_with_phone'];
    buttonUseMobileNumber = json['button_use_mobile_number'];
    buttonUseEmailInstead = json['button_use_email_instead'];
    buttonResendPhoneOtp = json['button_resend_phone_otp'];
    buttonResendEmailOtp = json['button_resend_email_otp'];
    buttonIAgree = json['button_i_agree'];
    buttonChangeMobileNumber = json['button_change_mobile_number'];
    buttonChangeEmailAddress = json['button_change_email_address'];
    buttonLoginWithPassword = json['button_login_with_password'];
    buttonForgotPassword = json['button_forgot_password'];
    buttonLoginWithOtp = json['button_login_with_otp'];
    buttonApplyFilter = json['button_apply_filter'];

    // Hints
    hintPhoneNumber = json['hint_phone_number'];
    hintDrivingLicense = json['hint_driving_license'];
    hintVehicleLicense = json['hint_vehicle_license'];
    headingCheckr = json['heading_checkr'];
    descriptionBackgroundVerification = json['description_background_verification'];
    descriptionCheckrInProgress = json['description_checkr_in_progress'];
    descriptionCheckrPending = json['description_checkr_pending'];
    descriptionCheckrVerified = json['description_checkr_verified'];
    descriptionCheckrReviewRequired = json['description_checkr_review_required'];
    descriptionDrivingLicense = json['description_driving_license'];
    hintFirstName = json['hint_first_name'];
    hintLastName = json['hint_last_name'];
    hintEmailExample = json['hint_email_example'];
    hintPassword = json['hint_password'];
    hintEnterPassword = json['hint_enter_password'];
    hintConfirmPassword = json['hint_confirm_password'];
    hintEnterReferralCode = json['hint_enter_referral_code'];
    hintSearch = json['hint_search'];
    hintMessage = json['hint_message'];
    hintSubject = json['hint_subject'];
    hintWriteSpecificReason = json['hint_write_specific_reason'];
    hintEnterConfirmationCode = json['hint_enter_confirmation_code'];

    // Headings
    headingEnterYourMobileNumber = json['heading_enter_your_mobile_number'];
    headingEnterYourEmail = json['heading_enter_your_email'];
    headingWhatIsYourName = json['heading_what_is_your_name'];
    headingAcceptTerms = json['heading_accept_terms'];
    headingHaveReferralCode = json['heading_have_referral_code'];
    headingVerifyAccount = json['heading_verify_account'];
    headingCreatePassword = json['heading_create_password'];
    headingResetPassword = json['heading_reset_password'];
    headingProfile = json['heading_profile'];
    headingDocument = json['heading_document'];
    headingInbox = json['heading_inbox'];
    headingReferral = json['heading_referral'];
    headingSetting = json['heading_setting'];
    headingSettings = json['heading_settings'];
    headingContactUs = json['heading_contact_us'];
    headingWallet = json['heading_wallet'];
    headingActivity = json['heading_activity'];
    headingUpcoming = json['heading_upcoming'];
    headingPast = json['heading_past'];
    headingOpportunities = json['heading_opportunities'];
    buttonIncentives = json['button_incentives'];
    buttonPenalties = json['button_penalties'];
    headingMarketplaceRide = json['heading_marketplace_ride'];
    errorNoBookingsFound = json['error_no_bookings_found'];
    headingEarnings = json['heading_earnings'];
    headingLogout = json['heading_logout'];
    headingCancelTrip = json['heading_cancel_trip'];
    headingWhyDoYouWantToCancel = json['heading_why_do_you_want_to_cancel'];
    headingCallUserSupport = json['heading_call_user_support'];
    headingConfirmation = json['heading_confirmation'];
    headingConfirmationCode = json['heading_confirmation_code'];
    headingInvoice = json['heading_invoice'];
    headingTripDetails = json['heading_trip_details'];
    headingCustomerDetails = json['heading_customer_details'];
    headingHelpAndSafety = json['heading_help_and_safety'];
    headingCancelBooking = json['heading_cancel_booking'];
    headingAbn = json['heading_abn'];
    headingAccount = json['heading_account'];
    headingAdditionalTerms = json['heading_additional_terms'];
    headingApplicationForm = json['heading_application_form'];
    headingAssessment = json['heading_assessment'];
    headingEnterVehicleInfo = json['heading_enter_vehicle_info'];
    headingLearningCenter = json['heading_learning_center'];
    headingManageAccount = json['heading_manage_account'];
    headingPayment = json['heading_payment'];
    headingPoliceCheck = json['heading_police_check'];
    headingPrivacy = json['heading_privacy'];
    headingSelectBusiness = json['heading_select_business'];
    headingVehicles = json['heading_vehicles'];
    headingWorkHub = json['heading_work_hub'];
    buttonCancelBooking = json['button_cancel_booking'];
    buttonGoBack = json['button_go_back'];
    buttonGetHelp = json['button_get_help'];

    // Descriptions
    descriptionTermsOfUse = json['description_terms_of_use'];
    descriptionPrivacyNotice = json['description_privacy_notice'];
    descriptionAgreeTermsPrivacy = json['description_agree_terms_privacy'];
    descriptionEmail = json['description_email'];
    descriptionPhone = json['description_phone'];
    descriptionPassword = json['description_password'];
    descriptionMale = json['description_male'];
    descriptionFemale = json['description_female'];
    descriptionNotSet = json['description_not_set'];
    descriptionPending = json['description_pending'];
    descriptionUploaded = json['description_uploaded'];
    descriptionAccepted = json['description_accepted'];
    descriptionRejected = json['description_rejected'];
    descriptionCancelled = json['description_cancelled'];
    descriptionCancelTrip = json['description_cancel_trip'];
    descriptionCancellationChargeWillBeApplied =
        json['description_cancellation_charge_will_be_applied'];
    descriptionOthers = json['description_others'];
    descriptionStatusAlertComing = json['description_status_alert_coming'];
    descriptionStatusAlertArrived = json['description_status_alert_arrived'];
    descriptionStatusAlertStart = json['description_status_alert_start'];
    descriptionStatusAlertStopHere = json['description_status_alert_stop_here'];
    descriptionStatusAlertEnd = json['description_status_alert_end'];
    descriptionStatusAlertPickedCourier =
        json['description_status_alert_picked_courier'];
    descriptionStatusAlertDroppedCourier =
        json['description_status_alert_dropped_courier'];
    descriptionEarning = json['description_earning'];
    descriptionRideWithCustomer = json['description_ride_with_customer'];
    descriptionReasonPrefix = json['description_reason_prefix'];
    descriptionSelectReasonForCancellation = json['description_select_reason_for_cancellation'];
    descriptionEstimatedPrice = json['description_estimated_price'];
    descriptionPaymentMode = json['description_payment_mode'];
    descriptionInvoiceCollectCash = json['description_invoice_collect_cash'];
    descriptionFrom = json['description_from'];
    descriptionTo = json['description_to'];
    descriptionNoDataFound = json['description_no_data_found'];
    descriptionHome = json['description_home'];
    descriptionWork = json['description_work'];
    descriptionLanguage = json['description_language'];
    descriptionLightMode = json['description_light_mode'];
    descriptionDarkMode = json['description_dark_mode'];
    descriptionSystemDefault = json['description_system_default'];
    descriptionLogout = json['description_logout'];
    descriptionAppVersion = json['description_app_version'];
    descriptionToday = json['description_today'];
    descriptionTomorrow = json['description_tomorrow'];
    descriptionYesterday = json['description_yesterday'];
    descriptionDistance = json['description_distance'];
    descriptionDuration = json['description_duration'];
    descriptionPickup = json['description_pickup'];
    descriptionDropOff = json['description_drop_off'];
    descriptionDestination = json['description_destination'];
    descriptionPayment = json['description_payment'];
    descriptionCash = json['description_cash'];
    descriptionWallet = json['description_wallet'];
    descriptionStripe = json['description_stripe'];
    descriptionPaystack = json['description_paystack'];
    descriptionRazorpay = json['description_razorpay'];
    descriptionMercadoPago = json['description_mercado_pago'];
    descriptionPayu = json['description_payu'];
    descriptionPago = json['description_pago'];
    descriptionZaincash = json['description_zaincash'];
    descriptionHyperpay = json['description_hyperpay'];
    descriptionNestpay = json['description_nestpay'];
    descriptionQicard = json['description_qicard'];
    descriptionMpesa = json['description_mpesa'];
    descriptionDistanceUnitKm = json['description_distance_unit_km'];
    descriptionDistanceUnitMi = json['description_distance_unit_mi'];
    descriptionMinutesUnit = json['description_minutes_unit'];
    descriptionHoursUnit = json['description_hours_unit'];
    descriptionChat = json['description_chat'];
    descriptionNoMessagesYet = json['description_no_messages_yet'];
    descriptionFailedToLoadImage = json['description_failed_to_load_image'];
    descriptionAdmin = json['description_admin'];
    descriptionBankPending = json['description_bank_pending'];
    descriptionBankProcessing = json['description_bank_processing'];
    descriptionBankTransfer = json['description_bank_transfer'];
    descriptionBankVerified = json['description_bank_verified'];
    descriptionBookingPayment = json['description_booking_payment'];
    descriptionBookingProfit = json['description_booking_profit'];
    descriptionCancelBookingPayment = json['description_cancel_booking_payment'];
    descriptionCurrentMonth = json['description_current_month'];
    descriptionDigitalPayment = json['description_digital_payment'];
    descriptionFromFriend = json['description_from_friend'];
    descriptionLast7Days = json['description_last_7_days'];
    descriptionLowRating = json['description_low_rating'];
    descriptionMissedRides = json['description_missed_rides'];
    descriptionNoPastBookingsFound = json['description_no_past_bookings_found'];
    descriptionNoUpcomingBookings = json['description_no_upcoming_bookings'];
    descriptionNoUpcomingBookingsSub = json['description_no_upcoming_bookings_sub'];
    descriptionPrevious6Months = json['description_previous_6_months'];
    descriptionPreviousMonth = json['description_previous_month'];
    descriptionReferrerBonus = json['description_referrer_bonus'];
    descriptionRefund = json['description_refund'];
    descriptionRefundReason = json['description_refund_reason'];
    descriptionBookingRemainingAmount = json['description__booking_remaining_amount'];
    descriptionRideCancellation = json['description_ride_cancellation'];
    descriptionSpecificDates = json['description_specific_dates'];
    descriptionSubscription = json['description_subscription'];
    descriptionTipPayment = json['description_tip_payment'];
    descriptionToFriend = json['description_to_friend'];
    descriptionTaxi = json['description_taxi'];
    descriptionDelivery = json['description_delivery'];
    descriptionCourier = json['description_courier'];

    // Errors
    errorPleaseEnterPhoneNumber = json['error_please_enter_phone_number'];
    errorPleaseEnterValidPhoneNumber = json['error_please_enter_valid_phone_number'];
    errorPleaseEnterEmail = json['error_please_enter_email'];
    errorPleaseEnterValidEmail = json['error_please_enter_valid_email'];
    errorPleaseEnterPassword = json['error_please_enter_password'];
    errorPleaseEnterOtp = json['error_please_enter_otp'];
    errorPleaseEnterRedeemPoint = json['error_please_enter_redeem_point'];
    errorPleaseValidRedeemPoint = json['error_please_valid_redeem_point'];
    errorEnterValidRedeemPoint = json['error_enter_valid_redeem_point'];
    errorSocialLoginFailed = json['error_social_login_failed'];
    errorPleaseAcceptTerms = json['error_please_accept_terms'];
    errorInvalidReferralCode = json['error_invalid_referral_code'];
    errorPasswordConfirmMismatch = json['error_password_confirm_mismatch'];
    errorPleaseEnterValidFirstName = json['error_please_enter_valid_first_name'];
    errorPleaseAddLicense = json['error_please_add_license'];
    errorPleaseEnterVehicleLicense = json['error_please_enter_vehicle_license'];
    errorPleaseEnterValidLastName = json['error_please_enter_valid_last_name'];
    errorAmountIsMoreThanWithdrawLimit = json['error_amount_is_more_than_withdraw_limit'];
    errorLocationNotAvailable = json['error_location_not_available'];
    errorNoHubFound = json['error_no_hub_found'];
    errorNoTermsAvailable = json['error_no_terms_available'];
    errorPdfLoadFailed = json['error_pdf_load_failed'];
    errorPleaseAcceptAdditionalTerms = json['error_please_accept_additional_terms'];
    errorPleaseCompleteAssessment = json['error_please_complete_assessment'];
    errorPleaseDownloadApplicationForm = json['error_please_download_application_form'];
    errorPleaseEnterCardName = json['error_please_enter_card_name'];
    errorPleaseEnterValidAmount = json['error_please_enter_valid_amount'];
    errorPleaseEnterValidCardNumber = json['error_please_enter_valid_card_number'];
    errorPleaseEnterValidCvv = json['error_please_enter_valid_cvv'];
    errorPleaseEnterValidExpiryDate = json['error_please_enter_valid_expiry_date'];
    errorPleaseEnterWalletAmount = json['error_please_enter_wallet_amount'];
    errorPleaseSelectBusiness = json['error_please_select_business'];
    errorPleaseSelectCard = json['error_please_select_card'];
    errorPleaseSubmitAbn = json['error_please_submit_abn'];
    errorPleaseSubmitPoliceCheck = json['error_please_submit_police_check'];

    // Booking Status
    bookingStatusRequested = json['booking_status_requested'];
    descriptionDriverAccepted = json['description_driver_accepted'];
    bookingStatusInRoute = json['booking_status_in_route'];
    bookingStatusArrivedAtPickup = json['booking_status_arrived_at_pickup'];
    bookingStatusStarted = json['booking_status_started'];

    // Booking Screen
    descriptionCompletedTrips = json['description_completed_trips'];
    descriptionTime = json['description_time'];
    descriptionWaitingTime = json['description_waiting_time'];
    descriptionStopWaitingTime = json['description_stop_waiting_time'];
    descriptionTrafficTime = json['description_traffic_time'];
    descriptionTotalDistance = json['description_total_distance'];
    descriptionTotalTime = json['description_total_time'];
    headingYouWillEarn = json['heading_you_will_earn'];
    descriptionYouWillEarnByAcceptingTheBooking = json['description_you_will_earn_by_accepting_the_booking'];
    buttonComing = json['button_coming'];
    buttonArrivedAtPickUp = json['button_arrived_at_pick_up'];
    buttonTapWhenYouStart = json['button_tap_when_you_start'];
    buttonTapWhenYouArrivedAtStop = json['button_tap_when_you_arrived_at_stop'];
    buttonSwipeToPickOrder = json['button_swipe_to_pick_order'];
    buttonDropOrder = json['button_drop_order'];
    buttonTapTwiceEndBooking = json['button_tap_twice_end_booking'];
    buttonMoveBooking = json['button_move_booking'];
    buttonSwitchBooking = json['button_switch_booking'];
    headingSwitchBooking = json['heading_switch_booking'];
    hintTypeAnythingHere = json['hint_type_anything_here'];
    descriptionPlatformProfitValue = json['description_platform_profit_value'];

    // Ride Types
    descriptionNormal = json['description_normal'];
    descriptionShare = json['description_share'];
    descriptionRental = json['description_rental'];
    descriptionFixGroupBooking = json['description_fix_group_booking'];

    // Missing Information
    subHeadingMissingInformation = json['sub_heading_missing_information'];
    errorPleaseEnterConfirmationCode =
        json['error_please_enter_confirmation_code'];
    errorPleaseUpdateProfile = json['error_please_update_profile'];
    errorPleaseUpdateMandatoryDocument = json['error_please_update_mandatory_document'];
    errorNotApprovedYet = json['error_not_approved_yet'];
    descriptionYourAccountIsDeclined = json['description_your_account_is_declined'];
    descriptionYourAccountIsBlocked = json['description_your_account_is_blocked'];
    descriptionByContinuingYouAgree = json['description_by_continuing_you_agree'];
    hintCountry = json['hint_country'];
    hintCity = json['hint_city'];
    headingCountries = json['heading_countries'];
    headingCities = json['heading_cities'];
    hintSearchCountry = json['hint_search_country'];
    hintSearchCity = json['hint_search_city'];
    textSelectCountry = json['text_select_country'];
    textSelectCity = json['text_select_city'];
    errorPleaseUpdateCountry = json['error_please_update_country'];
    errorPleaseUpdateCity = json['error_please_update_city'];
    errorPleaseAddVehicle = json['error_please_add_vehicle'];
    errorPleaseUpdateMandatoryVehicleDocument = json['error_please_update_mandatory_vehicle_document'];
    subHeadingVehicleDocument = json['sub_heading_vehicle_document'];
    headingAvailability = json['heading_availability'];
    errorNoAvailabilityAdded = json['error_no_availability_added'];
    errorAdminReviewYourProfile = json['error_admin_review_your_profile'];
    errorAdminDocRejected = json['error_admin_doc_rejected'];
    errorAdminDocExpired = json['error_admin_doc_expired'];
    errorAdminVehicleRejected = json['error_admin_vehicle_rejected'];
    errorAdminVehicleDocRejected = json['error_admin_vehicle_doc_rejected'];
    errorAdminVehicleDocExpired = json['error_admin_vehicle_doc_expired'];
    textRequiredActions = json['text_required_actions'];
    textGoOnlineWhenResolved = json['text_go_online_when_resolved'];
    textPleaseContactSupport = json['text_please_contact_support'];

    // Home Screen
    textYoureOffline = json['text_youre_offline'];
    textYoureOnline = json['text_youre_online'];
    buttonGo = json['button_go'];
    buttonPickVehicle = json['button_pick_vehicle'];
    buttonDropVehicle = json['button_drop_vehicle'];
    errorWalletLimitCash = json['error_wallet_limit_cash'];

    // Profile Screen
    headingName = json['heading_name'];
    headingDriverInfo = json['heading_driver_info'];
    descriptionUniqueId = json['description_unique_id'];
    descriptionRating = json['description_rating'];
    descriptionVehicleStatus = json['description_vehicle_status'];
    descriptionVehicleAdded = json['description_vehicle_added'];
    descriptionVehicleNotAdded = json['description_vehicle_not_added'];
    descriptionDocumentStatus = json['description_document_status'];
    descriptionUploadProfile = json['description_upload_profile'];
    descriptionCamera = json['description_camera'];
    descriptionImage = json['description_image'];
    descriptionProfileName = json['description_profile_name'];
    descriptionProfileEmail = json['description_profile_email'];
    descriptionYouWillUseThisNumber = json['description_you_will_use_this_number'];
    descriptionYouWillUseThisEmail = json['description_you_will_use_this_email'];
    descriptionVerificationCodeSendToNumber = json['description_verification_code_send_to_number'];
    descriptionEnterOtpSentTo = json['description_enter_otp_sent_to'];
    descriptionResendPhoneCode = json['description_resend_phone_code'];
    descriptionResendEmailCode = json['description_resend_email_code'];
    descriptionProfilePicPending = json['description_profile_pic_pending'];
    descriptionProfilePicAccepted = json['description_profile_pic_accepted'];
    descriptionProfilePicRejected = json['description_profile_pic_rejected'];
    descriptionProfilePicUploaded = json['description_profile_pic_uploaded'];

    // Document Screen
    subHeadingAdd = json['sub_heading_add'];
    subHeadingEdit = json['sub_heading_edit'];
    hintDocumentId = json['hint_document_id'];
    hintUniqueId = json['hint_unique_id'];
    hintExpiryDate = json['hint_expiry_date'];
    descriptionUploadDocument = json['description_upload_document'];
    descriptionPdf = json['description_pdf'];
    errorNoDocumentFound = json['error_no_document_found'];
    errorPleaseDocumentId = json['error_please_document_id'];
    errorPleaseExpiryDate = json['error_please_expiry_date'];
    errorPleaseSelectImage = json['error_please_select_image'];
    errorPleaseUpdateDocument = json['error_please_update_document'];
    successDocumentUpdated = json['success_document_updated'];
    errorDocumentUpdateFailed = json['error_document_update_failed'];
    headingSelectDate = json['heading_select_date'];
    headingSelectPhoneCode = json['heading_select_phone_code'];

    // Earning Screen
    descriptionTodaysEarning = json['description_todays_earning'];
    descriptionNetEarning = json['description_net_earning'];
    descriptionCashOnHand = json['description_cash_on_hand'];
    descriptionCompletedRides = json['description_completed_rides'];
    descriptionIncentive = json['description_incentive'];
    descriptionCancelledRides = json['description_cancelled_rides'];
    descriptionPenalty = json['description_penalty'];
    descriptionCancelledByOther = json['description_cancelled_by_other'];
    descriptionOnlineTime = json['description_online_time'];
    headingBookings = json['heading_bookings'];
    descriptionNoEarningsFound = json['description_no_earnings_found'];
    buttonSelectDateRange = json['button_select_date_range'];
    subHeadingEarningStatistics = json['sub_heading_earning_statistics'];
    descriptionEarningTotalEarning = json['description_earning_total_earning'];
    descriptionEarningCompletedRides = json['description_earning_completed_rides'];
    descriptionTotalCancelledBooking = json['description_total_cancelled_booking'];
    descriptionDeduction = json['description_deduction'];
    buttonViewDetails = json['button_view_details'];

    // Help / Contact Us / Support Tickets
    headingHelp = json['heading_help'];
    headingSubscription = json['heading_subscription'];
    descriptionActiveSubscriptions = json['description_active_subscriptions'];
    descriptionAvailableSubscriptions = json['description_available_subscriptions'];
    descriptionFreeTrial = json['description_free_trial'];
    descriptionValueDays = json['description_value_days'];
    descriptionValueFreeTrial = json['description_value_free_trial'];
    descriptionLifeTimePlan = json['description_life_time_plan'];
    descriptionBenefits = json['description_benefits'];
    descriptionPaymentPending = json['description_payment_pending'];
    descriptionExpiresSoon = json['description_expires_soon'];
    descriptionExpiresInDays = json['description_expires_in_days'];
    descriptionCancelSubscription = json['description_cancel_subscription'];
    descriptionUpgradeSubscription = json['description_upgrade_subscription'];
    descriptionMarketplaceAccess = json['description_marketplace_access'];
    descriptionApplyIncentive = json['description_apply_incentive'];
    descriptionApplyReward = json['description_apply_reward'];
    descriptionMaxBookingsPerDay = json['description_max_bookings_per_day'];
    descriptionMaxBiddingBookings = json['description_max_bidding_bookings'];
    headingBiddingRequest = json['heading_bidding_request'];
    descriptionBiddingPrice = json['description_bidding_price'];
    buttonAcceptBid = json['button_accept_bid'];
    headingBiddingAmount = json['heading_bidding_amount'];
    hintEnterBidAmount = json['hint_enter_bid_amount'];
    errorDriverMaxBid = json['error_driver_max_bid'];
    descriptionMaxScheduledRides = json['description_max_scheduled_rides'];
    descriptionMaxCancelledBookings = json['description_max_cancelled_bookings'];
    descriptionMaxExtraBookings = json['description_max_extra_bookings'];
    descriptionMaxDailyRevenue = json['description_max_daily_revenue'];
    descriptionMaxTotalRevenue = json['description_max_total_revenue'];
    descriptionMinWalletBalance = json['description_min_wallet_balance'];
    buttonRenew = json['button_renew'];
    buttonUpgrade = json['button_upgrade'];
    buttonSubscribe = json['button_subscribe'];
    subHeadingActiveSubscription = json['sub_heading_active_subscription'];
    subHeadingSubscription = json['sub_heading_subscription'];
    buttonPurchaseSubscription = json['button_purchase_subscription'];
    buttonYesSure = json['button_yes_sure'];
    descriptionActionSubscription = json['description_action_subscription'];
    buttonViewBenefits = json['button_view_benefits'];
    buttonGoToSubscription = json['button_go_to_subscription'];
    descriptionSubscriptionInfo = json['description_subscription_info'];
    descriptionAdminProfit = json['description_admin_profit'];
    descriptionMaximumDailyBookingsReceived = json['description_maximum_daily_bookings_received'];
    descriptionMaximumCancelledBookingsAfterAccept = json['description_maximum_cancelled_bookings_after_accept'];
    descriptionMaximumDailyScheduledRides = json['description_maximum_daily_scheduled_rides'];
    errorNoRecordFound = json['error_no_record_found'];
    errorPleaseSelectSubscription = json['error_please_select_subscription'];
    headingTermsAndConditions = json['heading_terms_and_conditions'];
    headingRedeem = json['heading_redeem'];
    headingRedeemPoints = json['heading_redeem_points'];
    buttonRedeem = json['button_redeem'];
    hintEnterPoints = json['hint_enter_points'];
    descriptionAvailablePoints = json['description_available_points'];
    descriptionEquivalent = json['description_equivalent'];
    descriptionAvailablePointsValue = json['description_available_points_value'];
    descriptionBalance = json['description_balance'];
    errorNoRedeemHistoryFound = json['error_no_redeem_history_found'];
    descriptionReferralBonus = json['description_referral_bonus'];
    descriptionBookingBonus = json['description_booking_bonus'];
    descriptionReviewBonus = json['description_review_bonus'];
    descriptionTipBonus = json['description_tip_bonus'];
    descriptionDailyBookingAcceptedBonus = json['description_daily_booking_accepted_bonus'];
    descriptionDailyBookingCompletedBonus = json['description_daily_booking_completed_bonus'];
    descriptionAverageRatingBonus = json['description_average_rating_bonus'];
    descriptionRewardPointWithdraw = json['description_reward_point_withdraw'];
    descriptionRewardPointsValue = json['description_reward_points_value'];
    descriptionReferralProfitBonus = json['description_referral_profit_bonus'];
    descriptionAwardProfitBonus = json['description_award_profit_bonus'];
    descriptionThankYouForChoosing = json['description_thank_you_for_choosing'];
    buttonEmail = json['button_email'];
    buttonCall = json['button_call'];
    buttonRaiseNewTicket = json['button_raise_new_ticket'];
    descriptionNoTicketsFound = json['description_no_tickets_found'];
    headingRaiseNewTicket = json['heading_raise_new_ticket'];
    headingTicketDetail = json['heading_ticket_detail'];
    headingChatWithAppName = json['heading_chat_with_app_name'];
    descriptionSelectCategory = json['description_select_category'];
    buttonCloseTicket = json['button_close_ticket'];
    buttonReopenTicket = json['button_reopen_ticket'];
    descriptionTicketOpen = json['description_ticket_open'];
    descriptionTicketClosed = json['description_ticket_closed'];
    descriptionTicketReopen = json['description_ticket_reopen'];
    descriptionTicketCancelled = json['description_ticket_cancelled'];
    descriptionSupportTicketId = json['description_support_ticket_id'];
    descriptionBookingId = json['description_booking_id'];
    errorPleaseSelectTicketCategory =
        json['error_please_select_ticket_category'];
    errorPleaseEnterSubject = json['error_please_enter_subject'];
    errorPleaseSelectEnterMessage = json['error_please_select_enter_message'];

    // Settings Screen
    headingAppearance = json['heading_appearance'];
    descriptionSelectTheme = json['description_select_theme'];
    descriptionHeatMap = json['description_heat_map'];
    descriptionNavigationMap = json['description_navigation_map'];
    descriptionInAppGoogle = json['description_in_app_google'];
    descriptionGoogleMap = json['description_google_map'];
    descriptionWazeMap = json['description_waze_map'];
    headingDeleteAccount = json['heading_delete_account'];
    descriptionDeleteAccount = json['description_delete_account'];
    headingVerifyIdentity = json['heading_verify_identity'];
    descriptionSelectVerificationMethod = json['description_select_verification_method'];
    headingVerifyPassword = json['heading_verify_password'];
    descriptionEnterPasswordFor = json['description_enter_password_for'];
    descriptionEnterPasswordToDelete = json['description_enter_password_to_delete'];
    headingVerifyOtp = json['heading_verify_otp'];
    descriptionOtpSentTo = json['description_otp_sent_to'];
    hintEnterOtp = json['hint_enter_otp'];
    buttonResendOtp = json['button_resend_otp'];
    buttonVerify = json['button_verify'];
    headingSelectLanguage = json['heading_select_language'];
    descriptionDelete = json['description_delete'];
    descriptionSpeakingLanguage = json['description_speaking_language'];
    descriptionSelectVerbalLanguage = json['description_select_verbal_language'];
    headingEmergencyContacts = json['heading_emergency_contacts'];
    buttonAddContact = json['button_add_contact'];
    headingAddEmergencyContact = json['heading_add_emergency_contact'];
    errorPleaseEnterContactName = json['error_please_enter_contact_name'];
    descriptionNoEmergencyContacts = json['description_no_emergency_contacts'];
    descriptionSureCallSos = json['description_sure_call_sos'];
    descriptionSettingsGoingHome = json['description_settings_going_home'];
    descriptionSettingsGoingHomeDescription = json['description_settings_going_home_description'];
    descriptionAddAddress = json['description_add_address'];
    hintSearchLocation = json['hint_search_location'];
    buttonSetLocationOnMap = json['button_set_location_on_map'];
    descriptionGettingAddress = json['description_getting_address'];
    descriptionMoveMapToSelect = json['description_move_map_to_select'];

    // Payment / Wallet Screen
    headingPayments = json['heading_payments'];
    headingWalletHistory = json['heading_wallet_history'];
    buttonTransferMoney = json['button_transfer_money'];
    buttonAdd = json['button_add'];
    buttonAddNewCard = json['button_add_new_card'];
    buttonSend = json['button_send'];
    subHeadingPaymentMethods = json['sub_heading_payment_methods'];
    headingAddWalletAmount = json['heading_add_wallet_amount'];
    hintEnterAmount = json['hint_enter_amount'];
    headingAddCardDetails = json['heading_add_card_details'];
    hintCardHolderName = json['hint_card_holder_name'];
    hintCardNumber = json['hint_card_number'];
    hintCvv = json['hint_cvv'];
    headingDeleteCard = json['heading_delete_card'];
    descriptionDeleteCardMessage = json['description_delete_card_message'];
    headingSelectPaymentGateway = json['heading_select_payment_gateway'];
    headingSendMoney = json['heading_send_money'];
    hintNumberExample = json['hint_number_example'];
    hintEnterTransferAmount = json['hint_enter_transfer_amount'];
    descriptionCustomer = json['description_customer'];
    descriptionDriver = json['description_driver'];
    descriptionZoneQueueNo = json['description_zone_queue_no'];
    errorNoWalletHistoryFound = json['error_no_wallet_history_found'];
    descriptionTransactionId = json['description_transaction_id'];
    errorUserNotFound = json['error_user_not_found'];
    subHeadingBankAccounts = json['sub_heading_bank_accounts'];
    buttonAddNewBank = json['button_add_new_bank'];
    headingDeleteBank = json['heading_delete_bank'];
    descriptionDeleteBank = json['description_delete_bank'];
    descriptionBank = json['description_bank'];
    descriptionDebitAmount = json['description_debit_amount'];
    descriptionTaxAmount = json['description_tax_amount'];
    descriptionBankAmount = json['description_bank_amount'];
    headingTransferOptions = json['heading_transfer_options'];
    headingBankTransfer = json['heading_bank_transfer'];
    buttonSendToBank = json['button_send_to_bank'];
    hintEnterBankTransferAmount = json['hint_enter_bank_transfer_amount'];
    descriptionTaxBreakdown = json['description_tax_breakdown'];
    descriptionCard = json['description_card'];

    // Receipt Screen
    headingReceipt = json['heading_receipt'];
    descriptionThanksForRiding = json['description_thanks_for_riding'];
    descriptionThanksForRidingNoName = json['description_thanks_for_riding_no_name'];
    descriptionTotal = json['description_total'];
    descriptionSubtotal = json['description_subtotal'];
    descriptionFree = json['description_free'];
    descriptionMinimumFareApplied = json['description_minimum_fare_applied'];
    descriptionNoInvoiceData = json['description_no_invoice_data'];
    descriptionReceiptDisclaimer = json['description_receipt_disclaimer'];

    // Feedback Screen
    headingFeedback = json['heading_feedback'];
    subHeadingRateYourRideExperience = json['sub_heading_rate_your_ride_experience'];
    subHeadingComment = json['sub_heading_comment'];
    hintWriteYourRideExperience = json['hint_write_your_ride_experience'];
    buttonMaybeLater = json['button_maybe_later'];
    descriptionRateAwful = json['description_rate_awful'];
    descriptionRateSad = json['description_rate_sad'];
    descriptionRateGood = json['description_rate_good'];
    descriptionRateVeryGood = json['description_rate_very_good'];
    descriptionRateExcellent = json['description_rate_excellent'];
    descriptionRated = json['description_rated'];
    descriptionNotYetRated = json['description_not_yet_rated'];

    // Vehicle Screen
    headingAddVehicle = json['heading_add_vehicle'];
    headingEditVehicle = json['heading_edit_vehicle'];
    headingOtherVehicles = json['heading_other_vehicles'];
    headingVehicleType = json['heading_vehicle_type'];
    headingProvidingAccessibility = json['heading_providing_accessibility'];
    headingFallbackVehicles = json['heading_fallback_vehicles'];
    descriptionEv = json['description_ev'];
    descriptionSelectYear = json['description_select_year'];
    descriptionSelectBrand = json['description_select_brand'];
    descriptionSelectModel = json['description_select_model'];
    descriptionVehicleName = json['description_vehicle_name'];
    descriptionPlateNo = json['description_plate_no'];
    descriptionVehicleColor = json['description_vehicle_color'];
    descriptionVehicleYear = json['description_vehicle_year'];
    descriptionBrand = json['description_brand'];
    descriptionModel = json['description_model'];
    descriptionVehicleInfoExpiresSoon = json['description_vehicle_info_expires_soon'];
    descriptionVehiclePending = json['description_vehicle_pending'];
    descriptionVehicleRejected = json['description_vehicle_rejected'];
    descriptionVehicleDraft = json['description_vehicle_draft'];
    descriptionVehicleChangeAlertTitle = json['description_vehicle_change_alert_title'];
    descriptionInvoiceBookingFeeUnit = json['description_invoice_booking_fee_unit'];
    descriptionDistanceCharge = json['description_distance_charge'];
    descriptionTimeCharge = json['description_time_charge'];
    descriptionExpired = json['description_expired'];
    buttonAddVehicle = json['button_add_vehicle'];
    buttonManageVehicles = json['button_manage_vehicles'];
    buttonPick = json['button_pick'];
    buttonDrop = json['button_drop'];
    errorPleaseEnterVehicleName = json['error_please_enter_vehicle_name'];
    errorPleaseEnterVehicleColor = json['error_please_enter_vehicle_color'];
    errorPleaseEnterVehiclePlateNo = json['error_please_enter_vehicle_plate_no'];
    errorPleaseSelectVehicleYear = json['error_please_select_vehicle_year'];
    errorPleaseSelectVehicleBrand = json['error_please_select_vehicle_brand'];
    errorPleaseSelectVehicleModel = json['error_please_select_vehicle_model'];
    errorPleaseUpdateVehicle = json['error_please_update_vehicle'];
    errorPleaseSelectBrandFirst = json['error_please_select_brand_first'];
    headingConfirmVehicleChange = json['heading_confirm_vehicle_change'];
    descriptionConfirmVehicleChange = json['description_confirm_vehicle_change'];
    descriptionNoVehiclesFound = json['description_no_vehicles_found'];
    headingQrCode = json['heading_qr_code'];
    descriptionScanQrToPick = json['description_scan_qr_to_pick'];
    descriptionNoResults = json['description_no_results'];
    errorNoCountriesFound = json['error_no_countries_found'];
    errorNoCitiesFound = json['error_no_cities_found'];

    // Referral Screen
    descriptionReferralList = json['description_referral_list'];
    descriptionInviteYourFriendAndEarnMoney = json['description_invite_your_friend_and_earn_money'];
    buttonViewReferralPolicy = json['button_view_referral_policy'];
    descriptionYourReferralCode = json['description_your_referral_code'];
    descriptionTapToCopy = json['description_tap_to_copy'];
    buttonReferYourFriend = json['button_refer_your_friend'];
    successReferralCodeCopied = json['success_referral_code_copied'];
    descriptionShareReferralCode = json['description_share_referral_code'];
    headingReferralPolicy = json['heading_referral_policy'];

    // Permission
    headingPermissionRequired = json['heading_permission_required'];
    descriptionEnablePermissionInSettings = json['description_enable_permission_in_settings'];
    buttonOpenSettings = json['button_open_settings'];

    // Settings
    descriptionContactUpdated = json['description_contact_updated'];
    descriptionContactAdded = json['description_contact_added'];
    descriptionContactRemoved = json['description_contact_removed'];
    errorPleaseSelectOption = json['error_please_select_option'];
  }
}

/// Get string value based on business type, falls back to local string
String getString(dynamic value, String key) {
  final stringObject = _parseStringObject(value);

  if (stringObject != null) {
    final result = switch (businessTypeForString) {
      BusinessType.taxi =>
        stringObject.taxi?.isNotEmpty == true
            ? stringObject.taxi!
            : stringObject.common ?? '',
      BusinessType.quickDelivery =>
        stringObject.quickCommerce?.isNotEmpty == true
            ? stringObject.quickCommerce!
            : stringObject.common ?? '',
      BusinessType.delivery =>
        stringObject.delivery?.isNotEmpty == true
            ? stringObject.delivery!
            : stringObject.common ?? '',
      BusinessType.service =>
        stringObject.service?.isNotEmpty == true
            ? stringObject.service!
            : stringObject.common ?? '',
      BusinessType.courier =>
        stringObject.courier?.isNotEmpty == true
            ? stringObject.courier!
            : stringObject.common ?? '',
      _ => stringObject.common ?? '',
    };

    if (result.isNotEmpty) return result;
  }

  // If value is a non-null string, return it
  if (value != null && value.toString().isNotEmpty) {
    return value.toString();
  }

  // Fallback to local string
  return LocalStrings.getString(key);
}

/// Parse dynamic value to StringObject
StringObject? _parseStringObject(dynamic value) {
  if (value == null) return null;

  try {
    if (value is Map<String, dynamic>) {
      return StringObject.fromJson(value);
    } else if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return StringObject.fromJson(decoded);
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}
