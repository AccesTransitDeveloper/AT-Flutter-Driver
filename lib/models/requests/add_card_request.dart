import 'package:json_annotation/json_annotation.dart';

part 'add_card_request.g.dart';

@JsonSerializable()
class AddCardRequest {
  final String? countryId;
  final String? paymentMethod;

  AddCardRequest({
    this.countryId,
    this.paymentMethod,
  });

  factory AddCardRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCardRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddCardRequestToJson(this);
}
