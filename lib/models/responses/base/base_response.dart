class BaseResponse<T> {
  final String? message;
  final T? data;
  final String? bookingId;

  BaseResponse({
    this.message,
    this.data,
    this.bookingId,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResponse<T>(
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      bookingId: json['bookingId'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'bookingId': bookingId,
    };
  }

  bool get isSuccess => data != null;
}
