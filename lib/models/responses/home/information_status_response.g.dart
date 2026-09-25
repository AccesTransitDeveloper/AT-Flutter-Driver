// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'information_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InformationStatusResponse _$InformationStatusResponseFromJson(
  Map<String, dynamic> json,
) => InformationStatusResponse(
  informationStatus: json['informationStatus'] == null
      ? null
      : InformationStatus.fromJson(
          json['informationStatus'] as Map<String, dynamic>,
        ),
  cashBookingMinimumWallet: (json['cashBookingMinimumWallet'] as num?)?.toInt(),
);

Map<String, dynamic> _$InformationStatusResponseToJson(
  InformationStatusResponse instance,
) => <String, dynamic>{
  'informationStatus': instance.informationStatus,
  'cashBookingMinimumWallet': instance.cashBookingMinimumWallet,
};

InformationStatus _$InformationStatusFromJson(
  Map<String, dynamic> json,
) => InformationStatus(
  cityStatus: json['cityStatus'] as bool?,
  countryStatus: json['countryStatus'] as bool?,
  profileStatus: json['profileStatus'] as bool?,
  documentStatus: (json['documentStatus'] as num?)?.toInt(),
  vehicleApprovalStatus: (json['vehicleApprovalStatus'] as num?)?.toInt(),
  vehicleDocumentStatus: (json['vehicleDocumentStatus'] as num?)?.toInt(),
  vehicleStatus: json['vehicleStatus'] as bool?,
  availableStatus: json['availableStatus'] as bool?,
  creditStatus: json['creditStatus'] as bool?,
  subscriptionStatus: json['subscriptionStatus'] as bool?,
  assessmentStatus: (json['assessmentStatus'] as num?)?.toInt(),
  isApplicationFormDownloaded: json['isApplicationFormDownloaded'] as bool?,
  workflowTypes: (json['workflowTypes'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  isAbnSubmitted: json['isAbnSubmitted'] as bool?,
  isPoliceCheckSubmitted: json['isPoliceCheckSubmitted'] as bool?,
  isAdditionalTermsAccepted: json['isAdditionalTermsAccepted'] as bool?,
  isCheckrStatus: json['isCheckrStatus'] as bool?,
  assessment: json['assessment'] == null
      ? null
      : AssessmentConfig.fromJson(json['assessment'] as Map<String, dynamic>),
  applicationForm: json['applicationForm'] == null
      ? null
      : AssessmentConfig.fromJson(
          json['applicationForm'] as Map<String, dynamic>,
        ),
  abnConfig: json['abnConfig'] == null
      ? null
      : AssessmentConfig.fromJson(json['abnConfig'] as Map<String, dynamic>),
  policeCheckConfig: json['policeCheckConfig'] == null
      ? null
      : AssessmentConfig.fromJson(
          json['policeCheckConfig'] as Map<String, dynamic>,
        ),
  additionalTerms: (json['additionalTerms'] as List<dynamic>?)
      ?.map((e) => AdditionalTermsItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InformationStatusToJson(InformationStatus instance) =>
    <String, dynamic>{
      'cityStatus': instance.cityStatus,
      'countryStatus': instance.countryStatus,
      'profileStatus': instance.profileStatus,
      'documentStatus': instance.documentStatus,
      'vehicleApprovalStatus': instance.vehicleApprovalStatus,
      'vehicleDocumentStatus': instance.vehicleDocumentStatus,
      'vehicleStatus': instance.vehicleStatus,
      'availableStatus': instance.availableStatus,
      'creditStatus': instance.creditStatus,
      'subscriptionStatus': instance.subscriptionStatus,
      'assessmentStatus': instance.assessmentStatus,
      'isApplicationFormDownloaded': instance.isApplicationFormDownloaded,
      'workflowTypes': instance.workflowTypes,
      'isAbnSubmitted': instance.isAbnSubmitted,
      'isPoliceCheckSubmitted': instance.isPoliceCheckSubmitted,
      'isAdditionalTermsAccepted': instance.isAdditionalTermsAccepted,
  'isCheckrStatus': instance.isCheckrStatus,
      'assessment': instance.assessment,
      'applicationForm': instance.applicationForm,
      'abnConfig': instance.abnConfig,
      'policeCheckConfig': instance.policeCheckConfig,
      'additionalTerms': instance.additionalTerms,
    };
