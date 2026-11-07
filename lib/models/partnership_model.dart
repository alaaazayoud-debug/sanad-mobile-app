class PartnershipModel {
  final String id;
  final String userA;
  final String userB;
  final double balance; // موجب = لصالح userA
  final String currency;
  final DateTime createdAt;

  // حقول مساعدة (ليست بقاعدة البيانات)
  final String? partnerName;
  final String? partnerPhone;
  final String? lastTransactionDescription;
  final DateTime? lastTransactionDate;

  PartnershipModel({
    required this.id,
    required this.userA,
    required this.userB,
    this.balance = 0.0,
    this.currency = 'USD',
    required this.createdAt,
    this.partnerName,
    this.partnerPhone,
    this.lastTransactionDescription,
    this.lastTransactionDate,
  });

  factory PartnershipModel.fromMap(Map<String, dynamic> map) {
    return PartnershipModel(
      id: map['\$id'] ?? map['id'] ?? '',
      userA: map['user_a'] ?? '',
      userB: map['user_b'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_a': userA,
      'user_b': userB,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// الرصيد من منظور المستخدم الحالي
  double balanceFor(String userId) {
    if (userId == userA) return balance;
    return -balance;
  }

  /// ID الشريك (الطرف الآخر)
  String partnerIdFor(String userId) {
    return userId == userA ? userB : userA;
  }

  PartnershipModel copyWith({
    String? id,
    String? userA,
    String? userB,
    double? balance,
    String? currency,
    DateTime? createdAt,
    String? partnerName,
    String? partnerPhone,
    String? lastTransactionDescription,
    DateTime? lastTransactionDate,
  }) {
    return PartnershipModel(
      id: id ?? this.id,
      userA: userA ?? this.userA,
      userB: userB ?? this.userB,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      partnerName: partnerName ?? this.partnerName,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      lastTransactionDescription:
          lastTransactionDescription ?? this.lastTransactionDescription,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }
}
