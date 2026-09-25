import 'package:json_annotation/json_annotation.dart';

part 'submit_rating_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SubmitRatingRequest {
  final String? bookingId;
  final double? rate;
  final String? review;
  final int? rateTo;

  SubmitRatingRequest({
    this.bookingId,
    this.rate,
    this.review,
    this.rateTo,
  });

  factory SubmitRatingRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitRatingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitRatingRequestToJson(this);
}
