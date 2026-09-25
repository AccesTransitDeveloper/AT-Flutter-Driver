// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentConfig _$AssessmentConfigFromJson(Map<String, dynamic> json) =>
    AssessmentConfig(
      title: json['title'] as String?,
      description: json['description'] as String?,
      assessmentUrl: json['assessmentUrl'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$AssessmentConfigToJson(AssessmentConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'assessmentUrl': instance.assessmentUrl,
      'url': instance.url,
    };
