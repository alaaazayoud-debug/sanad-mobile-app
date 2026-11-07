import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/invoice_item_model.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../config/constants.dart';
import 'dart:convert';

class LedgerProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _confirmedBalance = 0.0;
  String _currentUserId = ''; 
  String _currentPartnershipId = '';
  RealtimeSubscription? _subscription;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get confirmedBalance => _confirmedBalance;

  /// تحميل المعاملات لشراكة معيّنة
  Future<void> loadTransactions(String partnershipId, String currentUserId) async {
    _currentPartnershipId = partnershipId;
    _isLoading = true;
    notifyListeners();

    try {
      final databases = AppwriteService().databases;
      
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.transactionsCollectionId,
        queries: [
          Query.equal('partnership_id', partnershipId),
          Query.orderAsc('created_at'),
        ]
      );

      _transactions = result.documents.map((doc) {
        final data = doc.data;
        List<InvoiceItem> itemsList = [];
        try {
          if (data['items'] != null && data['items'].toString().isNotEmpty) {
            final decoded = json.decode(data['items']) as List;
            itemsList = decoded.map((i) => InvoiceItem.fromMap(i)).toList();
          }
        } catch (_) {}

        return TransactionModel(
          id: doc.$id,
          partnershipId: data['partnership_id'],
          createdBy: data['created_by'],
          type: TransactionType.values.firstWhere((e) => e.name == data['type']),
          amount: (data['amount'] ?? 0).toDouble(),
          description: data['description'],
          items: itemsList,
          inputMode: data['input_mode'] == 'smart' ? InvoiceInputMode.smart : InvoiceInputMode.structured,
          status: data['status'] == 'confirmed' ? TransactionStatus.confirmed : TransactionStatus.pending,
          confirmedBy: data['confirmed_by'],
          confirmedAt: data['confirmed_at'] != null ? DateTime.parse(data['confirmed_at']) : null,
          isPaidImmediately: data['is_paid_immediately'] ?? false,
          createdAt: DateTime.parse(data['created_at']),
        );
      }).toList();

      _calculateBalance();
      _setupRealtime(partnershipId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل تحميل المعاملات.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setupRealtime(String partnershipId) {
    if (_subscription != null) return;

    final realtime = AppwriteService().realtime;
    _subscription = realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.transactionsCollectionId}.documents'
    ]);

    _subscription!.stream.listen((response) {
      final data = response.payload;
      if (data['partnership_id'] != partnershipId) return;

      if (response.events.contains('databases.*.collections.*.documents.*.create')) {
        // لو أنا اللي أنشأتها، المفروض هي انضافت محلياً بـ addTransaction فنتجاهل
        if (data['created_by'] == _currentUserId) return;
        
        loadTransactions(partnershipId, _currentUserId); // أبسط حل: نعيد تحميل القائمة
      } else if (response.events.contains('databases.*.collections.*.documents.*.update')) {
        loadTransactions(partnershipId, _currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  /// إضافة معاملة جديدة
  Future<bool> addTransaction({
    required String partnershipId,
    required String createdBy,
    required TransactionType type,
    required double amount,
    String? description,
    List<InvoiceItem> items = const [],
    InvoiceInputMode inputMode = InvoiceInputMode.smart,
    bool isPaidImmediately = false,
  }) async {
    try {
      final databases = AppwriteService().databases;
      final now = DateTime.now();
      final status = isPaidImmediately ? 'confirmed' : 'pending';
      
      String itemsJson = '';
      if (items.isNotEmpty) {
        itemsJson = json.encode(items.map((i) => i.toMap()).toList());
      }

      final doc = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.transactionsCollectionId,
        documentId: ID.unique(),
        data: {
          'partnership_id': partnershipId,
          'created_by': createdBy,
          'type': type.name,
          'amount': amount,
          'description': description,
          'items': itemsJson,
          'input_mode': inputMode.name,
          'status': status,
          'confirmed_by': isPaidImmediately ? createdBy : null,
          'confirmed_at': isPaidImmediately ? now.toIso8601String() : null,
          'is_paid_immediately': isPaidImmediately,
          'created_at': now.toIso8601String(),
        }
      );

      final newTx = TransactionModel(
        id: doc.$id,
        partnershipId: partnershipId,
        createdBy: createdBy,
        type: type,
        amount: amount,
        description: description,
        items: items,
        inputMode: inputMode,
        status: isPaidImmediately ? TransactionStatus.confirmed : TransactionStatus.pending,
        isPaidImmediately: isPaidImmediately,
        confirmedAt: isPaidImmediately ? now : null,
        createdAt: now,
      );

      _transactions.add(newTx);
      _calculateBalance();
      notifyListeners();
      
      // تحديث رصيد الشراكة في قاعدة البيانات
      if (isPaidImmediately) {
        _updatePartnershipBalance(partnershipId);
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'فشل إضافة المعاملة.';
      notifyListeners();
      return false;
    }
  }

  /// تأكيد معاملة (من البائع فقط)
  Future<bool> confirmTransaction(String transactionId, String userId) async {
    try {
      final databases = AppwriteService().databases;
      final now = DateTime.now();
      
      await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.transactionsCollectionId,
        documentId: transactionId,
        data: {
          'status': 'confirmed',
          'confirmed_by': userId,
          'confirmed_at': now.toIso8601String(),
        }
      );

      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index] = _transactions[index].copyWith(
          status: TransactionStatus.confirmed,
          confirmedBy: userId,
          confirmedAt: now,
        );
        _calculateBalance();
        notifyListeners();
        
        // تحديث الرصيد
        _updatePartnershipBalance(_currentPartnershipId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updatePartnershipBalance(String partnershipId) async {
    try {
      final databases = AppwriteService().databases;

      // قراءة الشراكة لمعرفة من هو user_a
      final pDoc = await databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.partnershipsCollectionId,
        documentId: partnershipId,
      );

      final userA = pDoc.data['user_a'];

      // الرصيد المخزن في DB = من منظور user_a
      // إذا كنت أنا user_a → confirmedBalance هو الرصيد الصح مباشرة
      // إذا كنت أنا user_b → الرصيد المخزن = -confirmedBalance
      double balanceToStore;
      if (_currentUserId == userA) {
        balanceToStore = _confirmedBalance;
      } else {
        balanceToStore = -_confirmedBalance;
      }

      await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.partnershipsCollectionId,
        documentId: partnershipId,
        data: {'balance': balanceToStore},
      );
    } catch (e) {
      print('_updatePartnershipBalance error: $e');
    }
  }

  /// حساب الرصيد من المعاملات المؤكّدة فقط
  /// المنطق: كل معاملة أرسلتها أنا = +amount (الشريك مدين لي)
  ///          كل معاملة أرسلها الشريك = -amount (أنا مدين له)
  void _calculateBalance() {
    _confirmedBalance = 0.0;
    for (final tx in _transactions) {
      if (tx.status != TransactionStatus.confirmed) continue;

      final isMine = tx.createdBy == _currentUserId;
      // معاملاتي → موجب (الشريك مدين لي)
      // معاملاته → سالب (أنا مدين له)
      _confirmedBalance += isMine ? tx.amount : -tx.amount;
    }
  }
}
