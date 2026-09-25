import 'package:json_annotation/json_annotation.dart';

part 'submit_invoice_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SubmitInvoiceRequest {
  final String? bookingId;

  SubmitInvoiceRequest({
    this.bookingId,
  });

  factory SubmitInvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitInvoiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitInvoiceRequestToJson(this);
}
