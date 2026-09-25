import 'package:json_annotation/json_annotation.dart';

part 'accessibility_response.g.dart';

@JsonSerializable()
class AccessibilityResponse {
  final List<Accessibility>? accessibilities;
  final List<CustomPrice>? customPrices;

  AccessibilityResponse({
    this.accessibilities,
    this.customPrices,
  });

  factory AccessibilityResponse.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilityResponseToJson(this);
}

@JsonSerializable()
class Accessibility {
  @JsonKey(name: '_id')
  final String? id;
  final String? accessibility;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isChecked;

  Accessibility({
    this.id,
    this.accessibility,
    this.isChecked = false,
  });

  factory Accessibility.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilityToJson(this);
}

@JsonSerializable()
class CustomPrice {
  @JsonKey(name: '_id')
  final String? id;
  final String? title;

  CustomPrice({
    this.id,
    this.title,
  });

  factory CustomPrice.fromJson(Map<String, dynamic> json) =>
      _$CustomPriceFromJson(json);

  Map<String, dynamic> toJson() => _$CustomPriceToJson(this);
}
