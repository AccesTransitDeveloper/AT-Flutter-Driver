import '../../models/destination_address.dart';

class GeocodeUtils {
  GeocodeUtils._();

  /// Parse Google Geocode API response into DestinationAddress.
  static DestinationAddress? parseGeocodeResponse(
    Map<String, dynamic> json,
    double fallbackLat,
    double fallbackLng,
  ) {
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    String? address;
    String? placeId;
    double? lat;
    double? lng;
    String? city;
    String? country;
    String? countryCode;
    String? postalCode;

    for (final result in results) {
      final r = result as Map<String, dynamic>;
      address ??= r['formatted_address'] as String?;
      placeId ??= r['place_id'] as String?;

      final geometry = r['geometry'] as Map<String, dynamic>?;
      if (geometry != null && lat == null) {
        final location = geometry['location'] as Map<String, dynamic>?;
        if (location != null) {
          lat = (location['lat'] as num?)?.toDouble();
          lng = (location['lng'] as num?)?.toDouble();
        }
      }

      final components = r['address_components'] as List<dynamic>?;
      if (components != null) {
        for (final comp in components) {
          final c = comp as Map<String, dynamic>;
          final types = (c['types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();
          if (types == null) continue;

          if (types.contains('locality') && city == null) {
            city = c['long_name'] as String?;
          }
          if (types.contains('country') && country == null) {
            country = c['long_name'] as String?;
            countryCode = c['short_name'] as String?;
          }
          if (types.contains('postal_code') && postalCode == null) {
            postalCode = c['long_name'] as String?;
          }
        }
      }

      if (address != null &&
          lat != null &&
          city != null &&
          country != null &&
          postalCode != null) {
        break;
      }
    }

    return DestinationAddress(
      address: address,
      latitude: lat ?? fallbackLat,
      longitude: lng ?? fallbackLng,
      city: city,
      country: country,
      countryCode: countryCode,
      postalCode: postalCode,
      placeId: placeId,
    );
  }
}
