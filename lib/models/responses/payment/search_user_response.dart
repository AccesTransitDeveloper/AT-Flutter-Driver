import 'package:json_annotation/json_annotation.dart';

part 'search_user_response.g.dart';

@JsonSerializable()
class SearchUserResponse {
  final SearchUser? user;

  SearchUserResponse({this.user});

  factory SearchUserResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchUserResponseToJson(this);
}

@JsonSerializable()
class SearchUser {
  final String? countryPhoneCode;
  final String? email;
  final String? firstName;
  final String? fullName;
  final String? fullPhone;
  @JsonKey(name: '_id')
  final String? odooId;
  final String? id;
  final String? imageUrl;
  final String? lastName;
  final String? phone;
  final int? type;

  SearchUser({
    this.countryPhoneCode,
    this.email,
    this.firstName,
    this.fullName,
    this.fullPhone,
    this.odooId,
    this.id,
    this.imageUrl,
    this.lastName,
    this.phone,
    this.type,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) =>
      _$SearchUserFromJson(json);

  Map<String, dynamic> toJson() => _$SearchUserToJson(this);
}
