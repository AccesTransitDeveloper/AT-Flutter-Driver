import 'package:json_annotation/json_annotation.dart';

part 'webview_dismiss_response.g.dart';

@JsonSerializable()
class WebViewDismissResponse {
  final String? bookingId;

  WebViewDismissResponse({
    this.bookingId,
  });

  factory WebViewDismissResponse.fromJson(Map<String, dynamic> json) =>
      _$WebViewDismissResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WebViewDismissResponseToJson(this);
}
