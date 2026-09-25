import 'package:json_annotation/json_annotation.dart';

part 'assessment_config.g.dart';

/// Reusable config model for Assessment, Application Form, ABN, and Police Check.
/// Kotlin uses the same `Assessment` class for all these.
@JsonSerializable()
class AssessmentConfig {
  final String? title;
  final String? description;
  final String? assessmentUrl;
  final String? url;

  AssessmentConfig({
    this.title,
    this.description,
    this.assessmentUrl,
    this.url,
  });

  factory AssessmentConfig.fromJson(Map<String, dynamic> json) =>
      _$AssessmentConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentConfigToJson(this);
}
