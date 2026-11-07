import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:appwrite/appwrite.dart';
import '../services/appwrite_service.dart';
import '../config/constants.dart';

enum AuthState {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  needsProfile,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _phoneNumber;
  String? _errorMessage;
  String? _tempUserId;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get phoneNumber => _phoneNumber;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String get userId => _currentUser?.id ?? _tempUserId ?? '';

  // تحويل رقم الهاتف إلى إيميل وهمي للمصادقة
  String _phoneToEmail(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$clean@sanad.app';
  }

  // كلمة السر الثابتة للمرحلة التجريبية
  static const String _pilotPassword = 'Sanad2024!pilot';

  /// ═══════════════════════════════════════════
  /// التحقق من وجود جلسة محفوظة (عند فتح التطبيق)
  /// إذا موجودة → يدخل مباشرة بدون كود
  /// ═══════════════════════════════════════════
  Future<void> checkSession() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final account = AppwriteService().account;
      final user = await account.get()
          .timeout(const Duration(seconds: 5));
      
      _tempUserId = user.$id;
      
      // جلب بيانات المستخدم من قاعدة البيانات
      final databases = AppwriteService().databases;
      try {
        final doc = await databases.getDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.usersCollectionId,
          documentId: user.$id,
        ).timeout(const Duration(seconds: 5));
        
        _currentUser = UserModel(
          id: doc.$id,
          phone: doc.data['phone'] ?? '',
          name: doc.data['name'] ?? '',
          createdAt: DateTime.parse(doc.data['created_at']),
        );
        _phoneNumber = _currentUser!.phone;
        _state = AuthState.authenticated;
      } catch (e) {
        // جلسة موجودة بس ما عنده بروفايل
        _state = AuthState.needsProfile;
      }
    } catch (e) {
      // ما في جلسة → يروح لصفحة تسجيل الدخول
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// ═══════════════════════════════════════════
  /// المستخدم أدخل رقم الهاتف → ننقله لشاشة الكود
  /// ═══════════════════════════════════════════
  Future<void> sendOtp(String phone) async {
    _state = AuthState.loading;
    _phoneNumber = phone;
    _errorMessage = null;
    notifyListeners();

    // مرحلة تجريبية: ما في SMS حقيقي، ننقله مباشرة
    await Future.delayed(const Duration(milliseconds: 300));
    _state = AuthState.otpSent;
    notifyListeners();
  }

  /// ═══════════════════════════════════════════
  /// التحقق من الكود التجريبي (0000) وإنشاء حساب حقيقي
  /// ═══════════════════════════════════════════
  Future<bool> verifyOtp(String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    // التحقق من الكود التجريبي
    if (otp != AppConstants.pilotOtpCode) {
      _state = AuthState.otpSent;
      _errorMessage = 'الكود غلط. استخدم ${AppConstants.pilotOtpCode}';
      notifyListeners();
      return false;
    }

    try {
      final account = AppwriteService().account;
      final email = _phoneToEmail(_phoneNumber ?? '');

      // أول شي: نمسح أي جلسة قديمة موجودة
      try {
        await account.deleteSession(sessionId: 'current');
      } catch (_) {} // طبيعي لو ما في جلسة

      // محاولة 1: تسجيل دخول (إذا الحساب موجود)
      try {
        await account.createEmailPasswordSession(
          email: email,
          password: _pilotPassword,
        );
        
        final user = await account.get();
        _tempUserId = user.$id;
        
        // جلب البروفايل من قاعدة البيانات
        return await _loadProfile();
        
      } on AppwriteException catch (e) {
        // الحساب غير موجود → ننشئ واحد جديد
        if (e.code == 401 || e.type == 'user_invalid_credentials') {
          try {
            final newUser = await account.create(
              userId: ID.unique(),
              email: email,
              password: _pilotPassword,
            );
            _tempUserId = newUser.$id;
            
            // تسجيل دخول بعد الإنشاء
            await account.createEmailPasswordSession(
              email: email,
              password: _pilotPassword,
            );
            
            // حساب جديد → يحتاج اسم
            _state = AuthState.needsProfile;
            notifyListeners();
            return true;
          } catch (createError) {
            print('Create account error: $createError');
            _state = AuthState.error;
            _errorMessage = 'فشل إنشاء الحساب. حاول مجدداً.';
            notifyListeners();
            return false;
          }
        }
        rethrow;
      }
    } catch (e) {
      print('verifyOtp error: $e');
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ. حاول مجدداً.';
      notifyListeners();
      return false;
    }
  }

  /// جلب بيانات المستخدم من قاعدة البيانات
  Future<bool> _loadProfile() async {
    final databases = AppwriteService().databases;
    try {
      final doc = await databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: _tempUserId!,
      );
      
      _currentUser = UserModel(
        id: doc.$id,
        phone: doc.data['phone'] ?? '',
        name: doc.data['name'] ?? '',
        createdAt: DateTime.parse(doc.data['created_at']),
      );
      _phoneNumber = _currentUser!.phone;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      // ما عنده بروفايل بعد
      _state = AuthState.needsProfile;
      notifyListeners();
      return true;
    }
  }

  /// ═══════════════════════════════════════════
  /// حفظ اسم المستخدم (مرة واحدة فقط بعد أول تسجيل)
  /// ═══════════════════════════════════════════
  Future<void> saveProfile(String name) async {
    if (_tempUserId == null) return;

    _state = AuthState.loading;
    notifyListeners();

    try {
      final databases = AppwriteService().databases;
      
      final doc = await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: _tempUserId!,
        data: {
          'phone': _phoneNumber ?? '',
          'name': name,
          'created_at': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(_tempUserId!)),
          Permission.delete(Role.user(_tempUserId!)),
        ],
      );

      _currentUser = UserModel(
        id: doc.$id,
        phone: doc.data['phone'] ?? '',
        name: doc.data['name'] ?? '',
        createdAt: DateTime.parse(doc.data['created_at']),
      );
      _state = AuthState.authenticated;
    } catch (e) {
      print('saveProfile error: $e');
      _state = AuthState.error;
      _errorMessage = 'فشل حفظ الملف الشخصي. حاول مجدداً.';
    }
    notifyListeners();
  }

  /// ═══════════════════════════════════════════
  /// تسجيل الخروج
  /// ═══════════════════════════════════════════
  Future<void> logout() async {
    try {
      final account = AppwriteService().account;
      await account.deleteSession(sessionId: 'current');
    } catch (e) {}
    
    _currentUser = null;
    _phoneNumber = null;
    _tempUserId = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
