import '../../models/responses/base/error_response.dart';
import '../../models/responses/base/header_response.dart';

enum Status {
  loading,
  success,
  error,
}

sealed class ResponseState<T> {
  final Status? status;
  final int? responseCode;
  final String? message;
  final T? data;
  final String? bookingId;
  final HeaderResponse? header;
  final ErrorResponse? error;

  const ResponseState({
    this.status,
    this.responseCode,
    this.message,
    this.data,
    this.bookingId,
    this.header,
    this.error,
  });
}

class Loading<T> extends ResponseState<T> {
  const Loading({Status? status}) : super(status: status ?? Status.loading);
}

class Success<T> extends ResponseState<T> {
  const Success({
    Status? status,
    int? responseCode,
    String? message,
    T? data,
    String? bookingId,
    HeaderResponse? header,
  }) : super(
          status: status ?? Status.success,
          responseCode: responseCode,
          message: message,
          data: data,
          bookingId: bookingId,
          header: header,
        );
}

class Error<T> extends ResponseState<T> {
  // Mirror the error message onto `message` so callers reading `response.message`
  // on an error still get the server message (previously it was always null).
  Error({
    Status? status,
    int? responseCode,
    ErrorResponse? error,
  }) : super(
          status: status ?? Status.error,
          responseCode: responseCode,
          error: error,
          message: error?.message,
        );
}
