import 'package:json_annotation/json_annotation.dart';

part 'missing_information_response.g.dart';

@JsonSerializable()
class MissingInformationResponse {
  final InformationStatus? informationStatus;
  final int? cashBookingMinimumWallet;

  MissingInformationResponse({
    this.informationStatus,
    this.cashBookingMinimumWallet,
  });

  factory MissingInformationResponse.fromJson(Map<String, dynamic> json) =>
      _$MissingInformationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MissingInformationResponseToJson(this);
}

@JsonSerializable()
class InformationStatus {
  final bool? creditStatus;
  final bool? vehicleStatus;
  final bool? profileStatus;
  final int? documentStatus;
  final bool? subscriptionStatus;

  InformationStatus({
    this.creditStatus,
    this.vehicleStatus,
    this.profileStatus,
    this.documentStatus,
    this.subscriptionStatus,
  });

  factory InformationStatus.fromJson(Map<String, dynamic> json) =>
      _$InformationStatusFromJson(json);

  Map<String, dynamic> toJson() => _$InformationStatusToJson(this);
}
