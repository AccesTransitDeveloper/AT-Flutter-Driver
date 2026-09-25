import 'package:json_annotation/json_annotation.dart';

part 'set_language_request.g.dart';

@JsonSerializable()
class SetLanguageRequest {
  final String? language;
  final List<String>? speakingLanguages;

  SetLanguageRequest({this.language, this.speakingLanguages});

  factory SetLanguageRequest.fromJson(Map<String, dynamic> json) =>
      _$SetLanguageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetLanguageRequestToJson(this);
}
