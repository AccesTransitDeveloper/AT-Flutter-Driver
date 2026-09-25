import 'package:json_annotation/json_annotation.dart';

part 'checkr_response.g.dart';

/// Payload of `POST checkr` — the `data` object of the response envelope.
///
/// ApiClient unwraps `{message, data}` through BaseResponse and passes the
/// inner object to `fromJsonT`, so this maps that object directly. The
/// important field is [continueUrl], opened in a WebView for the driver to
/// finish the background check.
@JsonSerializable()
class CheckrData {
  final String? checkId;
  final String? candidateId;
  final String? invitationId;
  final String? reportId;
  final int? status;
  final String? continueUrl;

  CheckrData({
    this.checkId,
    this.candidateId,
    this.invitationId,
    this.reportId,
    this.status,
    this.continueUrl,
  });

  factory CheckrData.fromJson(Map<String, dynamic> json) =>
      _$CheckrDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckrDataToJson(this);
}
