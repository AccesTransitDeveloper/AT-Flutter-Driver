import 'package:json_annotation/json_annotation.dart';

part 'select_address_request.g.dart';

@JsonSerializable()
class SelectAddressRequest {
  final bool? isAddressSelected;

  SelectAddressRequest({this.isAddressSelected});

  factory SelectAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$SelectAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SelectAddressRequestToJson(this);
}
