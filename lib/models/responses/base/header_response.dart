class HeaderResponse {
  final String? authorization;
  final String? id;

  HeaderResponse({
    this.authorization,
    this.id,
  });

  factory HeaderResponse.fromJson(Map<String, dynamic> json) {
    return HeaderResponse(
      authorization: json['authorization'] as String?,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorization': authorization,
      'id': id,
    };
  }
}
