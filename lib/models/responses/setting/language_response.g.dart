// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageResponse _$LanguageResponseFromJson(Map<String, dynamic> json) =>
    LanguageResponse(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$LanguageResponseToJson(LanguageResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'code': instance.code,
    };

LanguageListResponse _$LanguageListResponseFromJson(
  Map<String, dynamic> json,
) => LanguageListResponse(
  languages: (json['languages'] as List<dynamic>?)
      ?.map((e) => LanguageResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LanguageListResponseToJson(
  LanguageListResponse instance,
) => <String, dynamic>{'languages': instance.languages};
