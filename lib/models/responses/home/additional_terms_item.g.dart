// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'additional_terms_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdditionalTermsItem _$AdditionalTermsItemFromJson(Map<String, dynamic> json) =>
    AdditionalTermsItem(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      terms: json['terms'] as String?,
      isAccepted: json['isAccepted'] as bool?,
    );

Map<String, dynamic> _$AdditionalTermsItemToJson(
  AdditionalTermsItem instance,
) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'terms': instance.terms,
  'isAccepted': instance.isAccepted,
};
