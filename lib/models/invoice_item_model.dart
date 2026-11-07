class InvoiceItem {
  final String name;
  final double quantity;
  final double unitPrice;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 1).toDouble(),
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  InvoiceItem copyWith({
    String? name,
    double? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  /// محاولة parse من نص حر مثل "5 × 15" أو "5x15" أو "5*15"
  static InvoiceItem? tryParse(String text) {
    // Pattern: [اسم اختياري] رقم × رقم
    final pattern = RegExp(
      r'^(.*?)\s*(\d+\.?\d*)\s*[×xX\*]\s*(\d+\.?\d*)',
      unicode: true,
    );
    final match = pattern.firstMatch(text.trim());
    if (match != null) {
      final name = match.group(1)?.trim() ?? '';
      final qty = double.tryParse(match.group(2) ?? '') ?? 1;
      final price = double.tryParse(match.group(3) ?? '') ?? 0;
      return InvoiceItem(
        name: name.isNotEmpty ? name : 'صنف',
        quantity: qty,
        unitPrice: price,
      );
    }
    return null;
  }
}
