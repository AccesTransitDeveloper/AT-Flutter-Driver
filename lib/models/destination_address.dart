/// Address model used by map interface for geocoding results.
class DestinationAddress {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? postalCode;
  final String? placeId;
  final String? title;

  DestinationAddress({
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.countryCode,
    this.postalCode,
    this.placeId,
    this.title,
  });
}
