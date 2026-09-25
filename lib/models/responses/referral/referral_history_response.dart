import 'package:json_annotation/json_annotation.dart';

part 'referral_history_response.g.dart';

@JsonSerializable()
class ReferralHistoryResponse {
  final ReferralData? referral;

  ReferralHistoryResponse({
    this.referral,
  });

  factory ReferralHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralHistoryResponseToJson(this);
}

@JsonSerializable()
class ReferralData {
  final List<ReferralUser>? referrals;

  ReferralData({
    this.referrals,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) =>
      _$ReferralDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralDataToJson(this);
}

@JsonSerializable()
class ReferralUser {
  final String? firstName;
  final String? lastName;
  final String? countryPhoneCode;
  final String? phone;
  final String? imageUrl;

  ReferralUser({
    this.firstName,
    this.lastName,
    this.countryPhoneCode,
    this.phone,
    this.imageUrl,
  });

  factory ReferralUser.fromJson(Map<String, dynamic> json) =>
      _$ReferralUserFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralUserToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get formattedPhone {
    final code = countryPhoneCode ?? '';
    final number = phone ?? '';
    return '$code $number'.trim();
  }
}
