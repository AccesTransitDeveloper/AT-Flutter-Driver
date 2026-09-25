// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessibilityResponse _$AccessibilityResponseFromJson(
  Map<String, dynamic> json,
) => AccessibilityResponse(
  accessibilities: (json['accessibilities'] as List<dynamic>?)
      ?.map((e) => Accessibility.fromJson(e as Map<String, dynamic>))
      .toList(),
  customPrices: (json['customPrices'] as List<dynamic>?)
      ?.map((e) => CustomPrice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AccessibilityResponseToJson(
  AccessibilityResponse instance,
) => <String, dynamic>{
  'accessibilities': instance.accessibilities,
  'customPrices': instance.customPrices,
};

Accessibility _$AccessibilityFromJson(Map<String, dynamic> json) =>
    Accessibility(
      id: json['_id'] as String?,
      accessibility: json['accessibility'] as String?,
    );

Map<String, dynamic> _$AccessibilityToJson(Accessibility instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'accessibility': instance.accessibility,
    };

CustomPrice _$CustomPriceFromJson(Map<String, dynamic> json) =>
    CustomPrice(id: json['_id'] as String?, title: json['title'] as String?);

Map<String, dynamic> _$CustomPriceToJson(CustomPrice instance) =>
    <String, dynamic>{'_id': instance.id, 'title': instance.title};
