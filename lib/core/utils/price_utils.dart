/// Currency sign position constants
class SetCurrencySign {
  static const int left = 1;
  static const int right = 2;
}

/// Extension for applying price settings to double values
extension PriceSettingExtension on double {
  /// Formats price with currency sign based on direction
  String applyPriceSetting({
    required int currencyDirection,
    required String currencySign,
    required int decimalPointValue,
  }) {
    final formattedPrice = toStringAsFixed(decimalPointValue);
    if (currencySign.isEmpty) return formattedPrice;
    if (currencyDirection == SetCurrencySign.right) {
      return '$formattedPrice$currencySign';
    }
    return '$currencySign$formattedPrice';
  }
}

/// Extension for applying price settings to nullable double values
extension NullablePriceSettingExtension on double? {
  /// Formats price with currency sign based on direction, returns empty string if null
  String applyPriceSetting({
    required int currencyDirection,
    required String currencySign,
    required int decimalPointValue,
  }) {
    if (this == null) return '';
    return this!.applyPriceSetting(
      currencyDirection: currencyDirection,
      currencySign: currencySign,
      decimalPointValue: decimalPointValue,
    );
  }

  /// Returns 0 if null, otherwise the value (matches Kotlin's .toValue())
  double toValue() => this ?? 0;
}

/// Extension for formatting double values
extension DoubleFormatExtension on double {
  /// Formats double with specified decimal points
  String format(int decimalPoints) => toStringAsFixed(decimalPoints);
}

/// Extension for formatting nullable double values
extension NullableDoubleFormatExtension on double? {
  /// Formats double with specified decimal points, returns empty string if null
  String format(int decimalPoints) {
    if (this == null) return '';
    return this!.toStringAsFixed(decimalPoints);
  }
}

/// Extension for nullable String toValue
extension NullableStringToValue on String? {
  String toValue() => this ?? '';
}

/// Extension for nullable int toValue
extension NullableIntToValue on int? {
  int toValue() => this ?? 0;
}

/// Extension for nullable bool toValue
extension NullableBoolToValue on bool? {
  bool toValue() => this ?? false;
}
