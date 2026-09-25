/// Tax breakdown data for bank withdrawal display
class TaxData {
  final String? taxName;
  final String? taxAmount;
  final List<(String, String)>? subTaxList;
  final bool showDivider;

  const TaxData({
    this.taxName,
    this.taxAmount,
    this.subTaxList,
    this.showDivider = false,
  });
}
