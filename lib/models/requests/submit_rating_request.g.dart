// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_rating_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitRatingRequest _$SubmitRatingRequestFromJson(Map<String, dynamic> json) =>
    SubmitRatingRequest(
      bookingId: json['bookingId'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      review: json['review'] as String?,
      rateTo: (json['rateTo'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubmitRatingRequestToJson(
  SubmitRatingRequest instance,
) => <String, dynamic>{
  'bookingId': ?instance.bookingId,
  'rate': ?instance.rate,
  'review': ?instance.review,
  'rateTo': ?instance.rateTo,
};
