import 'package:json_annotation/json_annotation.dart';

import 'additional_terms_item.dart';
import 'assessment_config.dart';

part 'information_status_response.g.dart';

@JsonSerializable()
class InformationStatusResponse {
  final InformationStatus? informationStatus;
  final int? cashBookingMinimumWallet;

  InformationStatusResponse({
    this.informationStatus,
    this.cashBookingMinimumWallet,
  });

  factory InformationStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$InformationStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InformationStatusResponseToJson(this);
}

@JsonSerializable()
class InformationStatus {
  final bool? cityStatus;
  final bool? countryStatus;
  final bool? profileStatus;
  final int? documentStatus;
  final int? vehicleApprovalStatus;
  final int? vehicleDocumentStatus;
  final bool? vehicleStatus;
  final bool? availableStatus;
  final bool? creditStatus;
  final bool? subscriptionStatus;
  final int? assessmentStatus;
  final bool? isApplicationFormDownloaded;
  final List<int>? workflowTypes;
  final bool? isAbnSubmitted;
  final bool? isPoliceCheckSubmitted;
  final bool? isAdditionalTermsAccepted;
  final bool? isCheckrStatus;
  final AssessmentConfig? assessment;
  final AssessmentConfig? applicationForm;
  final AssessmentConfig? abnConfig;
  final AssessmentConfig? policeCheckConfig;
  final List<AdditionalTermsItem>? additionalTerms;

  InformationStatus({
    this.cityStatus,
    this.countryStatus,
    this.profileStatus,
    this.documentStatus,
    this.vehicleApprovalStatus,
    this.vehicleDocumentStatus,
    this.vehicleStatus,
    this.availableStatus,
    this.creditStatus,
    this.subscriptionStatus,
    this.assessmentStatus,
    this.isApplicationFormDownloaded,
    this.workflowTypes,
    this.isAbnSubmitted,
    this.isPoliceCheckSubmitted,
    this.isAdditionalTermsAccepted,
    this.isCheckrStatus,
    this.assessment,
    this.applicationForm,
    this.abnConfig,
    this.policeCheckConfig,
    this.additionalTerms,
  });

  factory InformationStatus.fromJson(Map<String, dynamic> json) =>
      _$InformationStatusFromJson(json);

  Map<String, dynamic> toJson() => _$InformationStatusToJson(this);
}
