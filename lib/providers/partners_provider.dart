import 'package:flutter/material.dart';
import '../models/partnership_model.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../config/constants.dart';

class PartnersProvider extends ChangeNotifier {
  List<PartnershipModel> _partnerships = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUserId = '';
  RealtimeSubscription? _subscription;

  List<PartnershipModel> get partnerships => _partnerships;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل قائمة الشركاء
  Future<void> loadPartnerships(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      final databases = AppwriteService().databases;
      
      // جلب الشراكات اللي أنا user_a فيها
      final resultA = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.partnershipsCollectionId,
        queries: [Query.equal('user_a', userId)],
      );
      
      // جلب الشراكات اللي أنا user_b فيها
      final resultB = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.partnershipsCollectionId,
        queries: [Query.equal('user_b', userId)],
      );

      final allDocs = [...resultA.documents, ...resultB.documents];
      
      List<PartnershipModel> loaded = [];
      for (var doc in allDocs) {
        final data = doc.data;
        final partnerId = data['user_a'] == userId ? data['user_b'] : data['user_a'];
        
        String pName = 'شريك';
        String pPhone = '';
        try {
          final pDoc = await databases.getDocument(
            databaseId: AppConstants.databaseId,
            collectionId: AppConstants.usersCollectionId,
            documentId: partnerId,
          );
          pName = pDoc.data['name'] ?? pName;
          pPhone = pDoc.data['phone'] ?? pPhone;
        } catch (_) {}
        
        loaded.add(PartnershipModel(
          id: doc.$id,
          userA: data['user_a'],
          userB: data['user_b'],
          balance: (data['balance'] ?? 0).toDouble(),
          currency: data['currency'] ?? 'USD',
          createdAt: DateTime.parse(data['created_at']),
          partnerName: pName,
          partnerPhone: pPhone,
        ));
      }
      
      _partnerships = loaded;
      _errorMessage = null;
    } catch (e) {
      print('loadPartnerships error: $e');
      _errorMessage = 'فشل تحميل الشركاء.';
    }

    _isLoading = false;
    notifyListeners();

    // تفعيل Realtime بعد أول تحميل
    _setupRealtime();
  }

  /// الاستماع لأي تغيير في الشراكات بشكل فوري
  void _setupRealtime() {
    if (_subscription != null) return;

    final realtime = AppwriteService().realtime;
    _subscription = realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.partnershipsCollectionId}.documents'
    ]);

    _subscription!.stream.listen((event) {
      final data = event.payload;
      // إذا يخصني → أعيد تحميل القائمة
      if (data['user_a'] == _currentUserId || data['user_b'] == _currentUserId) {
        loadPartnerships(_currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  /// إضافة شريك جديد
  Future<bool> addPartner(String userId, String partnerPhone, String partnerName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final databases = AppwriteService().databases;
      
      // 1. البحث عن الشريك برقم الهاتف
      final usersResult = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.equal('phone', partnerPhone)
        ]
      );

      String partnerId;
      if (usersResult.documents.isEmpty) {
        // الشريك غير مسجل، ننشئ له حساب وهمي مؤقت
        final newPartner = await databases.createDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.usersCollectionId,
          documentId: ID.unique(),
          data: {
            'phone': partnerPhone,
            'name': partnerName,
            'created_at': DateTime.now().toIso8601String(),
          }
        );
        partnerId = newPartner.$id;
      } else {
        partnerId = usersResult.documents.first.$id;
      }

      // 2. إنشاء الشراكة
      final pDoc = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.partnershipsCollectionId,
        documentId: ID.unique(),
        data: {
          'user_a': userId,
          'user_b': partnerId,
          'balance': 0.0,
          'currency': AppConstants.defaultCurrency,
          'created_at': DateTime.now().toIso8601String(),
        }
      );

      final newPartnership = PartnershipModel(
        id: pDoc.$id,
        userA: userId,
        userB: partnerId,
        balance: 0.0,
        currency: AppConstants.defaultCurrency,
        createdAt: DateTime.parse(pDoc.data['created_at']),
        partnerName: partnerName,
        partnerPhone: partnerPhone,
      );

      _partnerships.insert(0, newPartnership);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل إضافة الشريك.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
