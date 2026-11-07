import 'invoice_item_model.dart';

enum TransactionType {
  invoice,  // فاتورة
  payment,  // دفعة
  returnTx, // استرجاع
}

enum TransactionStatus {
  pending,   // بانتظار تأكيد البائع
  confirmed, // مؤكّدة
}

enum InvoiceInputMode {
  smart,      // نص حر مثل "5 ابر ديستون × 15"
  structured, // جدول: اسم، عدد، سعر
}

class TransactionModel {
  final String id;
  final String partnershipId;
  final String createdBy;
  final TransactionType type;
  final double amount;       // المبلغ الإجمالي (محسوب تلقائياً من البنود أو مدخَل يدوياً)
  final String? description; // وصف حر (للدفعات والاسترجاعات)
  final List<InvoiceItem> items; // بنود الفاتورة النظامية
  final InvoiceInputMode inputMode;
  final TransactionStatus status;
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final bool isPaidImmediately;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.partnershipId,
    required this.createdBy,
    required this.type,
    required this.amount,
    this.description,
    this.items = const [],
    this.inputMode = InvoiceInputMode.smart,
    this.status = TransactionStatus.pending,
    this.confirmedBy,
    this.confirmedAt,
    this.isPaidImmediately = false,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final itemsRaw = map['items'] as List<dynamic>? ?? [];
    return TransactionModel(
      id: map['\$id'] ?? map['id'] ?? '',
      partnershipId: map['partnership_id'] ?? '',
      createdBy: map['created_by'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.invoice,
      ),
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'],
      items: itemsRaw
          .map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      inputMode: InvoiceInputMode.values.firstWhere(
        (e) => e.name == map['input_mode'],
        orElse: () => InvoiceInputMode.smart,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      confirmedBy: map['confirmed_by'],
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'])
          : null,
      isPaidImmediately: map['is_paid_immediately'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partnership_id': partnershipId,
      'created_by': createdBy,
      'type': type.name,
      'amount': amount,
      'description': description,
      'items': items.map((e) => e.toMap()).toList(),
      'input_mode': inputMode.name,
      'status': status.name,
      'confirmed_by': confirmedBy,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'is_paid_immediately': isPaidImmediately,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == TransactionStatus.pending;
  bool get isConfirmed => status == TransactionStatus.confirmed;
  bool get hasItems => items.isNotEmpty;

  /// هل هذا المستخدم يقدر يأكّد المعاملة؟ (البائع فقط)
  bool canBeConfirmedBy(String userId) {
    return isPending && createdBy != userId;
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.invoice:
        return 'فاتورة';
      case TransactionType.payment:
        return 'دفعة';
      case TransactionType.returnTx:
        return 'استرجاع';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'بانتظار التأكيد';
      case TransactionStatus.confirmed:
        return 'مؤكّدة';
    }
  }

  TransactionModel copyWith({
    String? id,
    String? partnershipId,
    String? createdBy,
    TransactionType? type,
    double? amount,
    String? description,
    List<InvoiceItem>? items,
    InvoiceInputMode? inputMode,
    TransactionStatus? status,
    String? confirmedBy,
    DateTime? confirmedAt,
    bool? isPaidImmediately,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      partnershipId: partnershipId ?? this.partnershipId,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      items: items ?? this.items,
      inputMode: inputMode ?? this.inputMode,
      status: status ?? this.status,
      confirmedBy: confirmedBy ?? this.confirmedBy,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      isPaidImmediately: isPaidImmediately ?? this.isPaidImmediately,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
