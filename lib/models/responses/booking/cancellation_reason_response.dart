import 'package:json_annotation/json_annotation.dart';

part 'cancellation_reason_response.g.dart';

@JsonSerializable()
class CancellationReasonResponse {
  final List<CancellationReason>? cancellationReasons;

  CancellationReasonResponse({this.cancellationReasons});

  factory CancellationReasonResponse.fromJson(Map<String, dynamic> json) =>
      _$CancellationReasonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancellationReasonResponseToJson(this);
}

@JsonSerializable()
class CancellationReason {
  @JsonKey(name: '_id')
  final String? id;
  final int? type;
  final int? businessType;
  final String? reasons;

  CancellationReason({this.id, this.type, this.businessType, this.reasons});

  factory CancellationReason.fromJson(Map<String, dynamic> json) =>
      _$CancellationReasonFromJson(json);

  Map<String, dynamic> toJson() => _$CancellationReasonToJson(this);
}
