class StringObject {
  final String? common;
  final String? taxi;
  final String? quickCommerce;
  final String? delivery;
  final String? service;
  final String? courier;

  StringObject({
    this.common,
    this.taxi,
    this.quickCommerce,
    this.delivery,
    this.service,
    this.courier,
  });

  factory StringObject.fromJson(Map<String, dynamic> json) {
    return StringObject(
      common: json['COMMON'] as String?,
      taxi: json['TAXI'] as String?,
      quickCommerce: json['QUICK_COMMERCE'] as String?,
      delivery: json['DELIVERY'] as String?,
      service: json['SERVICE'] as String?,
      courier: json['COURIER'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'COMMON': common,
      'TAXI': taxi,
      'QUICK_COMMERCE': quickCommerce,
      'DELIVERY': delivery,
      'SERVICE': service,
      'COURIER': courier,
    };
  }
}
