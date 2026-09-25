import 'package:json_annotation/json_annotation.dart';

part 'language_response.g.dart';

@JsonSerializable()
class LanguageResponse {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? code;

  LanguageResponse({
    this.id,
    this.name,
    this.code,
  });

  factory LanguageResponse.fromJson(Map<String, dynamic> json) =>
      _$LanguageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageResponseToJson(this);
}

@JsonSerializable()
class LanguageListResponse {
  final List<LanguageResponse>? languages;

  LanguageListResponse({this.languages});

  factory LanguageListResponse.fromJson(Map<String, dynamic> json) =>
      _$LanguageListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageListResponseToJson(this);
}
