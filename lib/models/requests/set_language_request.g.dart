// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_language_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLanguageRequest _$SetLanguageRequestFromJson(Map<String, dynamic> json) =>
    SetLanguageRequest(
      language: json['language'] as String?,
      speakingLanguages: (json['speakingLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SetLanguageRequestToJson(SetLanguageRequest instance) =>
    <String, dynamic>{
      'language': instance.language,
      'speakingLanguages': instance.speakingLanguages,
    };
