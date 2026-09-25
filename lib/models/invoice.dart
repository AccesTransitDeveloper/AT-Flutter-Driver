/// Invoice line item for receipt display
class Invoice {
  final String? title;
  final String? subTitle;
  final bool? isFree;
  final String? discount;
  final String? amount;
  final List<InvoiceChild>? invoiceChild;

  const Invoice({
    this.title,
    this.subTitle,
    this.isFree,
    this.discount,
    this.amount,
    this.invoiceChild,
  });

  Invoice copyWith({
    String? title,
    String? subTitle,
    bool? isFree,
    String? discount,
    String? amount,
    List<InvoiceChild>? invoiceChild,
  }) {
    return Invoice(
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      isFree: isFree ?? this.isFree,
      discount: discount ?? this.discount,
      amount: amount ?? this.amount,
      invoiceChild: invoiceChild ?? this.invoiceChild,
    );
  }
}

/// Child item within an expandable invoice line
class InvoiceChild {
  final String? title;
  final String? amount;

  const InvoiceChild({
    this.title,
    this.amount,
  });
}
