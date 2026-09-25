class EntityDetailRequest {
  final String? countryCode;

  const EntityDetailRequest({this.countryCode});

  Map<String, dynamic> toJson() => {
        if (countryCode != null) 'countryCode': countryCode,
      };
}
