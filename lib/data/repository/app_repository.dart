import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/response_state.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/geocode_utils.dart';
import '../../core/providers/app_providers.dart';
import '../../models/requests/device_token_request.dart';
import '../../models/requests/firebase_device_token_request.dart';
import '../../models/requests/entity_detail_request.dart';
import '../../models/requests/check_registered_request.dart';
import '../../models/requests/generate_otp_request.dart';
import '../../models/requests/verify_otp_request.dart';
import '../../models/requests/sign_in_request.dart';
import '../../models/requests/sign_up_request.dart';
import '../../models/requests/add_address_request.dart';
import '../../models/requests/change_password_request.dart';
import '../../models/requests/update_profile_request.dart';
import '../../models/responses/auth/country_response.dart';
import '../../models/responses/auth/entity_detail_response.dart';
import '../../models/responses/auth/verify_otp_response.dart';
import '../../models/responses/document/document_response.dart';
import '../../models/responses/notification/notification_response.dart';
import '../../models/responses/referral/referral_history_response.dart';
import '../../models/responses/support/support_ticket_response.dart';
import '../../models/requests/support_ticket_request.dart';
import '../../models/requests/redeem_withdraw_request.dart';
import '../../models/responses/redeem/redeem_point_response.dart';
import '../../models/responses/setting/language_response.dart';
import '../../models/requests/set_language_request.dart';
import '../../models/responses/setting/emergency_contact_response.dart';
import '../../models/requests/emergency_contact_request.dart';
import '../../models/responses/opportunity/incentive_policy_response.dart';
import '../../models/responses/opportunity/penalty_policy_response.dart';
import '../../models/responses/setting/address_response.dart';
import '../../models/requests/select_address_request.dart';
import '../../models/responses/payment/transaction_credit_response.dart';
import '../../models/responses/payment/payment_gateway_response.dart';
import '../../models/responses/payment/card_response.dart';
import '../../models/responses/payment/add_card_intent_response.dart';
import '../../models/responses/payment/payment_intent_response.dart';
import '../../models/responses/payment/search_user_response.dart';
import '../../models/requests/wallet_payment_request.dart';
import '../../models/requests/add_card_request.dart';
import '../../models/requests/transfer_credit_request.dart';
import '../../models/responses/payment/add_bank_response.dart';
import '../../models/responses/payment/credit_withdraw_response.dart';
import '../../models/requests/withdraw_credit_request.dart';
import '../../models/requests/vehicle_add_update_request.dart';
import '../../models/requests/workflow_request.dart';
import '../../models/requests/pick_vehicle_request.dart';
import '../../models/requests/online_request.dart';
import '../../models/requests/business_type_request.dart';
import '../../models/requests/create_booking_request.dart';
import '../../models/requests/country_city_request.dart';
import '../../models/responses/vehicle/vehicle_type_response.dart';
import '../../models/responses/home/business_type_response.dart';
import '../../models/responses/home/subscription_detail_response.dart';
import '../../models/responses/subscription/subscription_response.dart';
import '../../models/requests/subscription_request.dart';
import '../../models/responses/vehicle/vehicle_list_response.dart';
import '../../models/responses/vehicle/vehicle_details_response.dart';
import '../../models/responses/vehicle/vehicle_brand_response.dart';
import '../../models/responses/vehicle/vehicle_color_response.dart';
import '../../models/responses/vehicle/vehicle_model_response.dart';
import '../../models/responses/vehicle/accessibility_response.dart';
import '../../models/responses/hub/nearest_hub_list_response.dart';
import '../../models/responses/auth/city_response.dart';
import '../../models/requests/checkr_request.dart';
import '../../models/responses/home/checkr_response.dart';
import '../../models/responses/home/information_status_response.dart';
import '../../models/destination_address.dart';
import '../../models/responses/booking/booking_detail_response.dart';
import '../../models/responses/marketplace/marketplace_response.dart';
import '../../models/responses/activity/activity_response.dart';
import '../../models/responses/booking/cancellation_reason_response.dart';
import '../../models/responses/booking/change_status_response.dart';
import '../../models/requests/accept_reject_booking_request.dart';
import '../../models/requests/change_status_booking_request.dart';
import '../../models/requests/cancel_booking_request.dart';
import '../../models/requests/submit_invoice_request.dart';
import '../../models/requests/submit_rating_request.dart';
import '../../models/requests/accept_bidding_request.dart';
import '../../models/responses/booking/bids_response.dart';

class AppRepository {
  final ApiClient apiClient;

  AppRepository(this.apiClient);

  Future<ResponseState<dynamic>> getToken(
      DeviceTokenRequest deviceTokenRequest) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.getToken,
      headers: {
        ApiParams.type: '3',
      },
      body: deviceTokenRequest.toJson(),
    );
  }

  Future<ResponseState<dynamic>> updateDeviceToken(
      FirebaseDeviceTokenRequest request) async {
    return apiClient.patch<dynamic>(
      ApiEndpoint.deviceToken,
      body: request.toJson(),
    );
  }

  Future<ResponseState<EntityDetailResponse>> getEntityDetail(
      EntityDetailRequest entityDetailRequest) async {
    return apiClient.post<EntityDetailResponse>(
      ApiEndpoint.getEntityDetail,
      body: entityDetailRequest.toJson(),
      fromJsonT: (json) =>
          EntityDetailResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<Map<String, dynamic>>> getLanguageStrings(
      String language) async {
    return apiClient.get<Map<String, dynamic>>(
      ApiEndpoint.getLanguageStrings,
      headers: {
        ApiParams.language: language,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ResponseState<CountryResponse>> getCountries() async {
    return apiClient.get<CountryResponse>(
      ApiEndpoint.getCountries,
      fromJsonT: (json) => CountryResponse.fromJson(json),
    );
  }

  Future<ResponseState<dynamic>> checkRegistered(
      CheckRegisteredRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.checkRegistered,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> generateOtp(GenerateOtpRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.generateOtp,
      body: request.toJson(),
    );
  }

  Future<ResponseState<VerifyOtpResponse>> verifyOtp(
      VerifyOtpRequest request) async {
    return apiClient.post<VerifyOtpResponse>(
      ApiEndpoint.verifyOtp,
      body: request.toJson(),
      fromJsonT: (json) => VerifyOtpResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> signIn(SignInRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.signIn,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> signUp(SignUpRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.signUp,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> changePassword(
      ChangePasswordRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.changePassword,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> updateProfile(
      UpdateProfileRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.updateProfile,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> uploadProfilePicture(String filePath) async {
    return apiClient.putMultipart<dynamic>(
      ApiEndpoint.profilePicture,
      filePath: filePath,
      fileFieldName: 'imageUrl',
    );
  }

  Future<ResponseState<DocumentListResponse>> getDocuments() async {
    return apiClient.get<DocumentListResponse>(
      ApiEndpoint.getDocuments,
      fromJsonT: (json) => DocumentListResponse.fromJson(json),
    );
  }

  Future<ResponseState<DocumentListResponse>> getVehicleDocuments({
    required String vehicleId,
    required int type,
  }) async {
    return apiClient.get<DocumentListResponse>(
      ApiEndpoint.getDocuments,
      queryParameters: {
        ApiParams.typeId: vehicleId,
        ApiParams.type: type.toString(),
      },
      fromJsonT: (json) => DocumentListResponse.fromJson(json),
    );
  }

  Future<ResponseState<NotificationResponse>> getNotifications({
    required int page,
    required int limit,
    required String deviceType,
    required int userType,
    required int notificationType,
  }) async {
    return apiClient.get<NotificationResponse>(
      ApiEndpoint.getNotifications,
      queryParameters: {
        ApiParams.page: page.toString(),
        ApiParams.limit: limit.toString(),
        ApiParams.sortOrder: '-1',
        ApiParams.deviceType: deviceType,
        ApiParams.userType: userType.toString(),
        ApiParams.notificationType: notificationType.toString(),
      },
      fromJsonT: (json) => NotificationResponse.fromJson(json),
    );
  }

  Future<ResponseState<ReferralHistoryResponse>> getReferralHistory() async {
    return apiClient.get<ReferralHistoryResponse>(
      ApiEndpoint.referralHistory,
      fromJsonT: (json) => ReferralHistoryResponse.fromJson(json),
    );
  }

  Future<ResponseState<SupportTicketCategoriesResponse>>
      getSupportTicketCategories() async {
    return apiClient.get<SupportTicketCategoriesResponse>(
      ApiEndpoint.getSupportTicketCategories,
      fromJsonT: (json) =>
          SupportTicketCategoriesResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> createSupportTicket(
      SupportTicketRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.supportTicket,
      body: request.toJson(),
    );
  }

  Future<ResponseState<SupportTicketHistoryResponse>>
      getSupportTicketHistory() async {
    return apiClient.get<SupportTicketHistoryResponse>(
      ApiEndpoint.supportTicket,
      fromJsonT: (json) =>
          SupportTicketHistoryResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> addSupportTicketImage({
    required String ticketId,
    required String filePath,
  }) async {
    final path = ApiEndpoint.addSupportTicketImage
        .replaceAll('{ticketId}', ticketId);
    return apiClient.putMultipart<dynamic>(
      path,
      filePath: filePath,
      fileFieldName: 'imageUrl',
    );
  }

  Future<ResponseState<dynamic>> updateTicketStatus({
    required String ticketId,
    required TicketStatusRequest request,
  }) async {
    final path = ApiEndpoint.updateTicketStatus
        .replaceAll('{ticketId}', ticketId);
    return apiClient.patch<dynamic>(
      path,
      body: request.toJson(),
    );
  }

  Future<ResponseState<RedeemPointResponse>> getRewardPoints({
    required int page,
    int limit = 10,
  }) async {
    return apiClient.get<RedeemPointResponse>(
      ApiEndpoint.getRewardPoints,
      queryParameters: {
        ApiParams.page: page.toString(),
        ApiParams.limit: limit.toString(),
      },
      fromJsonT: (json) => RedeemPointResponse.fromJson(json),
    );
  }

  Future<ResponseState<dynamic>> withdrawRewardPoints(
      RedeemWithdrawRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.withdrawRewardPoints,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> signOut() async {
    return apiClient.post<dynamic>(ApiEndpoint.signOut, body: {});
  }

  Future<ResponseState<dynamic>> deleteAccount({
    Map<String, String>? body,
  }) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.deleteAccount,
      body: body ?? {},
    );
  }

  Future<ResponseState<List<LanguageResponse>>> getLanguages() async {
    return apiClient.get<List<LanguageResponse>>(
      ApiEndpoint.getLanguage,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => LanguageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ResponseState<dynamic>> setLanguage(SetLanguageRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.setLanguage,
      body: request.toJson(),
    );
  }

  // Emergency Contacts
  Future<ResponseState<EmergencyContactResponse>> getEmergencyContacts() async {
    return apiClient.get<EmergencyContactResponse>(
      ApiEndpoint.emergencyContact,
      fromJsonT: (json) => EmergencyContactResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<EmergencyContactResponse>> addEmergencyContact(
      EmergencyContactRequest request) async {
    return apiClient.post<EmergencyContactResponse>(
      ApiEndpoint.emergencyContact,
      body: request.toJson(),
      fromJsonT: (json) => EmergencyContactResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<EmergencyContactResponse>> updateEmergencyContact(
      String contactId, EmergencyContactRequest request) async {
    final path = ApiEndpoint.modifyEmergencyContact.replaceAll('{contactId}', contactId);
    return apiClient.put<EmergencyContactResponse>(
      path,
      body: request.toJson(),
      fromJsonT: (json) => EmergencyContactResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<EmergencyContactResponse>> deleteEmergencyContact(
      String contactId) async {
    final path = ApiEndpoint.modifyEmergencyContact.replaceAll('{contactId}', contactId);
    return apiClient.delete<EmergencyContactResponse>(
      path,
      fromJsonT: (json) => EmergencyContactResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // SOS
  Future<ResponseState<dynamic>> sosCall(String bookingId) async {
    final path = ApiEndpoint.sosCall.replaceAll('{bookingId}', bookingId);
    return apiClient.post<dynamic>(path);
  }

  // Opportunities
  Future<ResponseState<IncentivePolicyResponse>> getIncentivePolicy(
      String cityId) async {
    final path =
        ApiEndpoint.incentivePolicy.replaceAll('{cityId}', cityId);
    return apiClient.get<IncentivePolicyResponse>(
      path,
      fromJsonT: (json) =>
          IncentivePolicyResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<PenaltyPolicyResponse>> getPenaltyPolicy(
      String cityId) async {
    final path =
        ApiEndpoint.penaltyPolicy.replaceAll('{cityId}', cityId);
    return apiClient.get<PenaltyPolicyResponse>(
      path,
      fromJsonT: (json) =>
          PenaltyPolicyResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // Going Home Address
  Future<ResponseState<AddressResponse>> getAddresses() async {
    return apiClient.get<AddressResponse>(
      ApiEndpoint.address,
      fromJsonT: (json) => AddressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> selectAddress(
      String addressId, SelectAddressRequest request) async {
    final path = ApiEndpoint.modifyAddress.replaceAll('{addressId}', addressId);
    return apiClient.patch<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> addAddress(AddAddressRequest request) async {
    return apiClient.post<dynamic>(ApiEndpoint.address, body: request.toJson());
  }

  Future<ResponseState<dynamic>> deleteAddress(String addressId) async {
    final path = ApiEndpoint.modifyAddress.replaceAll('{addressId}', addressId);
    return apiClient.delete<dynamic>(path);
  }

  // ── Payment / Wallet ─────────────────────────────────────────────────

  Future<ResponseState<TransactionCreditResponse>> getTransactionCredit({
    required int page,
    int limit = 10,
  }) async {
    return apiClient.get<TransactionCreditResponse>(
      ApiEndpoint.getTransactionCredit,
      queryParameters: {
        ApiParams.page: page.toString(),
        ApiParams.limit: limit.toString(),
      },
      fromJsonT: (json) =>
          TransactionCreditResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<PaymentGatewayResponse>> getPaymentGateways({
    required String countryId,
  }) async {
    return apiClient.get<PaymentGatewayResponse>(
      ApiEndpoint.getPaymentGateways,
      queryParameters: {
        ApiParams.countryId: countryId,
      },
      fromJsonT: (json) =>
          PaymentGatewayResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<GetCardsResponse>> getCards({
    required String countryId,
    required String paymentGatewayTypes,
  }) async {
    return apiClient.get<GetCardsResponse>(
      ApiEndpoint.getCards,
      queryParameters: {
        ApiParams.countryId: countryId,
        ApiParams.paymentGatewayTypes: paymentGatewayTypes,
      },
      fromJsonT: (json) =>
          GetCardsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<AddCardIntentResponse>> addCardIntent({
    required String gateway,
    required String countryId,
  }) async {
    final path =
        ApiEndpoint.addCardIntent.replaceAll('{gateway}', gateway);
    return apiClient.post<AddCardIntentResponse>(
      path,
      body: {ApiParams.countryId: countryId},
      fromJsonT: (json) =>
          AddCardIntentResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> addCard({
    required String gateway,
    required AddCardRequest request,
  }) async {
    final path = ApiEndpoint.addCard.replaceAll('{gateway}', gateway);
    return apiClient.post<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> deleteCard({
    required String cardId,
  }) async {
    final path = ApiEndpoint.modifyCard.replaceAll('{cardId}', cardId);
    return apiClient.delete<dynamic>(path);
  }

  Future<ResponseState<PaymentIntentResponse>> paymentIntentCreate({
    required String paymentGateway,
    required WalletPaymentRequest request,
  }) async {
    final path = ApiEndpoint.paymentIntentCreate
        .replaceAll('{paymentGateway}', paymentGateway);
    return apiClient.post<PaymentIntentResponse>(
      path,
      body: request.toJson(),
      fromJsonT: (json) =>
          PaymentIntentResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> transferCredit({
    required TransferCreditRequest request,
  }) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.transferCredits,
      body: request.toJson(),
    );
  }

  Future<ResponseState<SearchUserResponse>> searchUser({
    required String countryPhoneCode,
    required String phone,
    required int type,
    required String id,
  }) async {
    return apiClient.get<SearchUserResponse>(
      ApiEndpoint.searchUser,
      queryParameters: {
        ApiParams.countryPhoneCode: countryPhoneCode,
        ApiParams.phone: phone,
        ApiParams.type: type.toString(),
        ApiParams.id: id,
      },
      fromJsonT: (json) =>
          SearchUserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Bank Account ──────────────────────────────────────────────────

  Future<ResponseState<GetCardsResponse>> getBank({
    required int paymentGateway,
  }) async {
    final path = ApiEndpoint.getBank
        .replaceAll('{payment_gateway}', paymentGateway.toString());
    return apiClient.get<GetCardsResponse>(
      path,
      fromJsonT: (json) =>
          GetCardsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<AddBankResponse>> addBank({
    required String gateway,
    required AddCardRequest request,
  }) async {
    final path = ApiEndpoint.addBank.replaceAll('{gateway}', gateway);
    return apiClient.post<AddBankResponse>(
      path,
      body: request.toJson(),
      fromJsonT: (json) =>
          AddBankResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> selectBank({
    required String bankId,
  }) async {
    final path = ApiEndpoint.selectBank.replaceAll('{bankId}', bankId);
    return apiClient.patch<dynamic>(path, body: {});
  }

  Future<ResponseState<dynamic>> deleteBank({
    required String bankId,
  }) async {
    final path = ApiEndpoint.addBank.replaceAll('{gateway}', bankId);
    return apiClient.delete<dynamic>(path);
  }

  Future<ResponseState<dynamic>> selectCard({
    required String cardId,
  }) async {
    final path = ApiEndpoint.modifyCard.replaceAll('{cardId}', cardId);
    return apiClient.patch<dynamic>(path, body: {});
  }

  Future<ResponseState<CreditWithdrawResponse>> getCreditWithdrawTaxDetail({
    required double amount,
  }) async {
    return apiClient.get<CreditWithdrawResponse>(
      ApiEndpoint.creditWithdrawTaxDetail,
      queryParameters: {'amount': amount.toString()},
      fromJsonT: (json) =>
          CreditWithdrawResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> withdrawCredit({
    required WithdrawCreditRequest request,
  }) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.creditWithdraw,
      body: request.toJson(),
    );
  }

  // ── Vehicle ──────────────────────────────────────────────────────

  Future<ResponseState<VehicleListResponse>> getVehicleList() async {
    return apiClient.get<VehicleListResponse>(
      ApiEndpoint.vehicle,
      fromJsonT: (json) =>
          VehicleListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<VehicleListResponse>> getHubVehicleList() async {
    return apiClient.get<VehicleListResponse>(
      ApiEndpoint.hubVehicle,
      fromJsonT: (json) =>
          VehicleListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<VehicleDetailsResponse>> getVehicleDetails({
    required String vehicleId,
  }) async {
    final path =
        ApiEndpoint.vehicleDetail.replaceAll('{vehicleId}', vehicleId);
    return apiClient.get<VehicleDetailsResponse>(
      path,
      fromJsonT: (json) =>
          VehicleDetailsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> addVehicle({
    required VehicleAddUpdateRequest request,
  }) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.vehicle,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> updateVehicle({
    required String vehicleId,
    required VehicleAddUpdateRequest request,
  }) async {
    final path =
        ApiEndpoint.vehicleDetail.replaceAll('{vehicleId}', vehicleId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<VehicleBrandResponse>> getVehicleBrand() async {
    return apiClient.get<VehicleBrandResponse>(
      ApiEndpoint.vehicleBrand,
      fromJsonT: (json) =>
          VehicleBrandResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<VehicleColorResponse>> getVehicleColor() async {
    return apiClient.get<VehicleColorResponse>(
      ApiEndpoint.vehicleColor,
      queryParameters: {'isActive': 'true'},
      fromJsonT: (json) =>
          VehicleColorResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<VehicleModelListResponse>> getVehicleModel({
    required String brandId,
  }) async {
    return apiClient.get<VehicleModelListResponse>(
      ApiEndpoint.vehicleModel,
      queryParameters: {ApiParams.brandId: brandId},
      fromJsonT: (json) =>
          VehicleModelListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> selectVehicle({
    required String vehicleId,
  }) async {
    final path =
        ApiEndpoint.selectVehicle.replaceAll('{vehicleId}', vehicleId);
    return apiClient.put<dynamic>(path, body: {});
  }

  Future<ResponseState<AccessibilityResponse>> getAccessibility() async {
    return apiClient.get<AccessibilityResponse>(
      ApiEndpoint.accessibility,
      fromJsonT: (json) =>
          AccessibilityResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> pickVehicle({
    required String vehicleId,
    required PickVehicleRequest request,
  }) async {
    final path =
        ApiEndpoint.pickVehicle.replaceAll('{vehicleId}', vehicleId);
    return apiClient.patch<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> dropVehicle({
    required String vehicleId,
  }) async {
    final path =
        ApiEndpoint.dropVehicle.replaceAll('{vehicleId}', vehicleId);
    return apiClient.patch<dynamic>(path, body: {});
  }

  Future<ResponseState<UploadDocumentResponse>> uploadDocument({
    required String documentId,
    String? filePath,
    String? expiryDate,
    String? uniqueCode,
  }) async {
    final path =
        ApiEndpoint.uploadDocument.replaceAll('{documentId}', documentId);
    final fields = <String, String>{};
    if (expiryDate != null) fields[ApiParams.expiryDate] = expiryDate;
    if (uniqueCode != null) fields[ApiParams.uniqueCode] = uniqueCode;
    return apiClient.putMultipart<UploadDocumentResponse>(
      path,
      filePath: filePath,
      fileFieldName: 'imageUrl',
      fields: fields.isNotEmpty ? fields : null,
      fromJsonT: (json) => UploadDocumentResponse.fromJson(json),
    );
  }
  // ── Driver Online/Offline ────────────────────────────────────────

  Future<ResponseState<dynamic>> online(OnlineRequest request) async {
    return apiClient.put<dynamic>(
      ApiEndpoint.driverOnline,
      body: request.toJson(),
    );
  }

  Future<ResponseState<dynamic>> offline() async {
    return apiClient.put<dynamic>(ApiEndpoint.driverOffline, body: {});
  }

  // ── Create Booking (driver-initiated taxi trip) ────────────────

  Future<ResponseState<dynamic>> createBooking(
      CreateBookingRequest request) async {
    return apiClient.post<dynamic>(
      ApiEndpoint.createBooking,
      body: request.toJson(),
    );
  }

  Future<ResponseState<GetVehicleTypeResponse>> getVehicleTypes(
      Map<String, dynamic> body) async {
    return apiClient.post<GetVehicleTypeResponse>(
      ApiEndpoint.getVehicleTypes,
      body: body,
      fromJsonT: (json) =>
          GetVehicleTypeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Business Type ──────────────────────────────────────────────

  Future<ResponseState<BusinessTypeResponse>> getBusinessType(
      BusinessTypeRequest request) async {
    return apiClient.post<BusinessTypeResponse>(
      ApiEndpoint.businessType,
      body: request.toJson(),
      fromJsonT: (json) =>
          BusinessTypeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Country/City ───────────────────────────────────────────────

  Future<ResponseState<CityResponse>> getCities({
    required String countryId,
  }) async {
    return apiClient.get<CityResponse>(
      ApiEndpoint.getCities,
      queryParameters: {ApiParams.countryId: countryId},
      fromJsonT: (json) =>
          CityResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> setCountryCity(
      CountryCityRequest request) async {
    return apiClient.put<dynamic>(
      ApiEndpoint.setCountryCity,
      body: request.toJson(),
    );
  }

  // ── Subscription ──────────────────────────────────────────────

  Future<ResponseState<SubscriptionVehicleInfoResponse>>
      getSubscriptionVehicleInfo() async {
    return apiClient.get<SubscriptionVehicleInfoResponse>(
      ApiEndpoint.subscriptionVehicleInfo,
      fromJsonT: (json) => SubscriptionVehicleInfoResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<SubscriptionResponse>> getSubscriptionVehicle() async {
    return apiClient.get<SubscriptionResponse>(
      ApiEndpoint.subscriptionVehicle,
      fromJsonT: (json) =>
          SubscriptionResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<PaymentIntentResponse>> subscriptionCreate({
    required String paymentGateway,
    required SubscriptionCreateRequest request,
  }) async {
    final path = ApiEndpoint.subscriptionCreate
        .replaceAll('{paymentGateway}', paymentGateway);
    return apiClient.post<PaymentIntentResponse>(
      path,
      body: request.toJson(),
      fromJsonT: (json) =>
          PaymentIntentResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> subscriptionUpgrade({
    required String vehicleSubscriptionId,
    required SubscriptionUpgradeRequest request,
  }) async {
    final path = ApiEndpoint.subscriptionUpgrade
        .replaceAll('{vehicleSubscriptionId}', vehicleSubscriptionId);
    return apiClient.patch<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<SubscriptionVehicleUpgradeResponse>>
      getSubscriptionVehicleUpgrade({
    required String vehicleSubscriptionId,
    required String subscriptionId,
  }) async {
    final path = ApiEndpoint.subscriptionVehicleUpgrade
        .replaceAll('{vehicleSubscriptionId}', vehicleSubscriptionId)
        .replaceAll('{subscriptionId}', subscriptionId);
    return apiClient.get<SubscriptionVehicleUpgradeResponse>(
      path,
      fromJsonT: (json) => SubscriptionVehicleUpgradeResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> subscriptionCancel({
    required String vehicleSubscriptionId,
  }) async {
    final path = ApiEndpoint.subscriptionCancel
        .replaceAll('{vehicleSubscriptionId}', vehicleSubscriptionId);
    return apiClient.delete<dynamic>(path);
  }

  Future<ResponseState<SubscriptionInvoiceResponse>> getSubscriptionInvoice({
    required String vehicleSubscriptionId,
  }) async {
    final path = ApiEndpoint.subscriptionInvoice
        .replaceAll('{vehicleSubscriptionId}', vehicleSubscriptionId);
    return apiClient.get<SubscriptionInvoiceResponse>(
      path,
      fromJsonT: (json) => SubscriptionInvoiceResponse.fromJson(
          json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<InformationStatusResponse>>
      getInformationStatus() async {
    return apiClient.get<InformationStatusResponse>(
      ApiEndpoint.informationStatus,
      fromJsonT: (json) =>
          InformationStatusResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Starts a Checkr background verification and returns the URL the driver
  /// must open to complete it.
  Future<ResponseState<CheckrData>> initiateCheckr(CheckrRequest request) async {
    return apiClient.post<CheckrData>(
      ApiEndpoint.checkr,
      body: request.toJson(),
      fromJsonT: (json) => CheckrData.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Hub ──────────────────────────────────────────────────────────

  Future<ResponseState<NearestHubListResponse>> getNearestHubList() async {
    return apiClient.get<NearestHubListResponse>(
      ApiEndpoint.nearestHub,
      fromJsonT: (json) =>
          NearestHubListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Workflow ─────────────────────────────────────────────────────

  Future<ResponseState<dynamic>> setWorkflow(WorkFlowRequest request) async {
    return apiClient.patch<dynamic>(
      ApiEndpoint.setWorkflow,
      body: request.toJson(),
    );
  }

  // ── Additional Terms ────────────────────────────────────────────

  Future<ResponseState<dynamic>> acceptAdditionalTerms(String id) async {
    final path = '${ApiEndpoint.acceptAdditionalTerms}/$id';
    return apiClient.patch<dynamic>(path, body: {});
  }

  // ── Booking ──────────────────────────────────────────────────────

  Future<ResponseState<BookingDetailResponse>> getBookingDetail(
      String bookingId) async {
    final path =
        ApiEndpoint.bookingDetail.replaceAll('{bookingId}', bookingId);
    return apiClient.get<BookingDetailResponse>(
      path,
      fromJsonT: (json) =>
          BookingDetailResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> acceptBooking(
      String bookingId, AcceptRejectBookingRequest request) async {
    final path =
        ApiEndpoint.acceptBooking.replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> rejectBooking(
      String bookingId, AcceptRejectBookingRequest request) async {
    final path =
        ApiEndpoint.rejectBooking.replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<ChangeStatusResponse>> changeBookingStatus(
      String bookingId, ChangeStatusBookingRequest request) async {
    final path =
        ApiEndpoint.changeBookingStatus.replaceAll('{bookingId}', bookingId);
    return apiClient.put<ChangeStatusResponse>(
      path,
      body: request.toJson(),
      fromJsonT: (json) =>
          ChangeStatusResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> cancelBooking(
      String bookingId, CancelBookingRequest request) async {
    final path =
        ApiEndpoint.cancelBooking.replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> getCancellationCharge(
      String bookingId) async {
    final path =
        ApiEndpoint.cancellationCharge.replaceAll('{bookingId}', bookingId);
    return apiClient.get<dynamic>(path);
  }

  Future<ResponseState<CancellationReasonResponse>>
      getCancellationReasons({Map<String, dynamic>? queryParams}) async {
    return apiClient.get<CancellationReasonResponse>(
      ApiEndpoint.cancellationReason,
      queryParameters: queryParams,
      fromJsonT: (json) =>
          CancellationReasonResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> calling(String bookingId) async {
    final path = ApiEndpoint.calling.replaceAll('{bookingId}', bookingId);
    return apiClient.post<dynamic>(path, body: {});
  }

  Future<ResponseState<dynamic>> supportCalling() async {
    return apiClient.post<dynamic>(ApiEndpoint.supportCalling, body: {});
  }

  Future<ResponseState<dynamic>> submitInvoice(
      String bookingId, SubmitInvoiceRequest request) async {
    final path =
        ApiEndpoint.submitInvoice.replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  Future<ResponseState<dynamic>> submitRating(
      String bookingId, SubmitRatingRequest request) async {
    final path =
        ApiEndpoint.submitRating.replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: request.toJson());
  }

  // ── Bidding ──────────────────────────────────────────────────────

  Future<ResponseState<BidsResponse>> getBids() async {
    return apiClient.get<BidsResponse>(
      ApiEndpoint.bids,
      fromJsonT: (json) =>
          BidsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> acceptBidding(
      String bookingId, AcceptBiddingRequest request) async {
    return apiClient.put<dynamic>(
        '${ApiEndpoint.acceptBidding}/$bookingId',
        body: request.toJson());
  }

  // ── Marketplace ────────────────────────────────────────────────────

  Future<ResponseState<MarketplaceResponse>> getMarketplaceBookings() async {
    return apiClient.get<MarketplaceResponse>(
      ApiEndpoint.marketplaceBookingList,
      fromJsonT: (json) =>
          MarketplaceResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<dynamic>> acceptMarketplaceBooking(
      String bookingId) async {
    final path = ApiEndpoint.acceptMarketplaceBooking
        .replaceAll('{bookingId}', bookingId);
    return apiClient.put<dynamic>(path, body: {});
  }

  // ── My Bookings (Upcoming/Active) ──────────────────────────────────

  Future<ResponseState<MyBookingListResponse>> getMyBookings() async {
    return apiClient.get<MyBookingListResponse>(
      ApiEndpoint.myBookings,
      fromJsonT: (json) =>
          MyBookingListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetch currently active/running bookings (mirrors Kotlin bookingList with isNowBooking=true).
  Future<ResponseState<MyBookingListResponse>> getActiveBookings() async {
    return apiClient.get<MyBookingListResponse>(
      ApiEndpoint.myBookings,
      queryParameters: {'isNowBooking': 'true'},
      fromJsonT: (json) =>
          MyBookingListResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Geocoding ──────────────────────────────────────────────────────

  /// Reverse geocode coordinates via Google Geocode API proxy.
  /// Called by MapManager's getPlaceDetailWithCoordinates.
  Future<DestinationAddress?> reverseGeocode({
    required double latitude,
    required double longitude,
    required String apiKey,
  }) async {
    try {
      final json = await apiClient.getRaw(
        ApiEndpoint.googleGeocode,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': apiKey,
        },
      );
      if (json == null) return null;
      return GeocodeUtils.parseGeocodeResponse(json, latitude, longitude);
    } catch (e) {
      debugPrint('reverseGeocode error: $e');
      return null;
    }
  }
}

final appRepositoryProvider = Provider<AppRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppRepository(apiClient);
});
