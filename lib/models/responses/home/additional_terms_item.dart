import 'package:json_annotation/json_annotation.dart';

part 'additional_terms_item.g.dart';

@JsonSerializable()
class AdditionalTermsItem {
  @JsonKey(name: '_id')
  final String? id;
  final String? title;
  final String? terms;
  final bool? isAccepted;

  AdditionalTermsItem({
    this.id,
    this.title,
    this.terms,
    this.isAccepted,
  });

  factory AdditionalTermsItem.fromJson(Map<String, dynamic> json) =>
      _$AdditionalTermsItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdditionalTermsItemToJson(this);
}
