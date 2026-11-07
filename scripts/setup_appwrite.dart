import 'package:dart_appwrite/dart_appwrite.dart';
import 'dart:io';

Future<void> main() async {
  final endpoint = 'https://fra.cloud.appwrite.io/v1';
  final projectId = '6a8ab8ed003d63d5f766';
  final apiKey = 'standard_90fa6f4976bf04498ba21dcf3d6dfec0ee4f5243a5d76db2cd260b9051b9a0ef73903ca81ccf469cce3bd63efcc1a4dffcfd38f60947a1e81c072960d4e6b932ef65b19613f2736ddc677abe6a7f42f65606ad6ed799ffb24b6b1bf1d199e0abb6ae68a53ddba624a9ef89bc55e6f3032dd205666a8d26816357cebcb96a5201';

  print('⏳ تهيئة عميل Appwrite...');
  final client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setKey(apiKey);

  final databases = Databases(client);
  String dbId = 'sanad_db';

  try {
    // جلب قواعد البيانات الموجودة
    final dbs = await databases.list();
    if (dbs.databases.isNotEmpty) {
      dbId = dbs.databases.first.$id;
      print('ℹ️ تم العثور على قاعدة بيانات موجودة مسبقاً: \$dbId. سنستخدمها.');
    } else {
      print('📦 إنشاء قاعدة البيانات...');
      await databases.create(databaseId: dbId, name: 'Sanad Database');
      print('✅ تم إنشاء قاعدة البيانات \$dbId');
    }

    // 2. إنشاء مجموعة المستخدمين
    print('👥 إعداد مجموعة المستخدمين (users)...');
    try {
      await databases.createCollection(
        databaseId: dbId,
        collectionId: 'users',
        name: 'Users',
        documentSecurity: true,
        permissions: [
          Permission.read(Role.any()), 
        ],
      );
      print('✅ تم إنشاء مجموعة المستخدمين');
      
      await _createStringAttr(databases, dbId, 'users', 'phone', 20, true);
      await _createStringAttr(databases, dbId, 'users', 'name', 100, true);
      await _createDatetimeAttr(databases, dbId, 'users', 'created_at', true);
    } on AppwriteException catch (e) {
      if (e.code == 409) print('ℹ️ مجموعة المستخدمين موجودة مسبقاً.');
      else rethrow;
    }

    // 3. إنشاء مجموعة الشراكات
    print('🤝 إعداد مجموعة الشراكات (partnerships)...');
    try {
      await databases.createCollection(
        databaseId: dbId,
        collectionId: 'partnerships',
        name: 'Partnerships',
        documentSecurity: true,
      );
      print('✅ تم إنشاء مجموعة الشراكات');
      
      await _createStringAttr(databases, dbId, 'partnerships', 'user_a', 36, true);
      await _createStringAttr(databases, dbId, 'partnerships', 'user_b', 36, true);
      await _createFloatAttr(databases, dbId, 'partnerships', 'balance', false, 0.0);
      await _createStringAttr(databases, dbId, 'partnerships', 'currency', 10, true);
      await _createDatetimeAttr(databases, dbId, 'partnerships', 'created_at', true);
    } on AppwriteException catch (e) {
      if (e.code == 409) print('ℹ️ مجموعة الشراكات موجودة مسبقاً.');
      else rethrow;
    }

    // 4. إنشاء مجموعة المعاملات
    print('💸 إعداد مجموعة المعاملات (transactions)...');
    try {
      await databases.createCollection(
        databaseId: dbId,
        collectionId: 'transactions',
        name: 'Transactions',
        documentSecurity: true,
      );
      print('✅ تم إنشاء مجموعة المعاملات');
      
      await _createStringAttr(databases, dbId, 'transactions', 'partnership_id', 36, true);
      await _createStringAttr(databases, dbId, 'transactions', 'created_by', 36, true);
      await _createStringAttr(databases, dbId, 'transactions', 'type', 20, true); 
      await _createFloatAttr(databases, dbId, 'transactions', 'amount', true, null);
      await _createStringAttr(databases, dbId, 'transactions', 'description', 500, false);
      await _createStringAttr(databases, dbId, 'transactions', 'items', 2000, false); 
      await _createStringAttr(databases, dbId, 'transactions', 'input_mode', 20, false); 
      await _createStringAttr(databases, dbId, 'transactions', 'status', 20, true); 
      await _createStringAttr(databases, dbId, 'transactions', 'confirmed_by', 36, false);
      await _createDatetimeAttr(databases, dbId, 'transactions', 'confirmed_at', false);
      await _createBooleanAttr(databases, dbId, 'transactions', 'is_paid_immediately', false, false);
      await _createDatetimeAttr(databases, dbId, 'transactions', 'created_at', true);
    } on AppwriteException catch (e) {
      if (e.code == 409) print('ℹ️ مجموعة المعاملات موجودة مسبقاً.');
      else rethrow;
    }

    print('🎉 اكتمل إعداد قاعدة البيانات بنجاح!');
    
    // Save the dbId to a file so we can update constants.dart
    File('db_id.txt').writeAsStringSync(dbId);
    
    exit(0);

  } catch (e) {
    print('❌ حدث خطأ غير متوقع: `$e');
    exit(1);
  }
}

Future<void> _createStringAttr(Databases db, String dbId, String colId, String key, int size, bool req) async {
  try {
    await db.createStringAttribute(databaseId: dbId, collectionId: colId, key: key, size: size, xrequired: req);
    print('   - عمود \$key مُضاف');
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    if (e.toString().contains('409')) return; 
    print('   ⚠️ فشل إضافة \$key');
  }
}

Future<void> _createFloatAttr(Databases db, String dbId, String colId, String key, bool req, double? def) async {
  try {
    await db.createFloatAttribute(databaseId: dbId, collectionId: colId, key: key, xrequired: req, xdefault: def);
    print('   - عمود \$key مُضاف');
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    if (e.toString().contains('409')) return; 
    print('   ⚠️ فشل إضافة \$key');
  }
}

Future<void> _createBooleanAttr(Databases db, String dbId, String colId, String key, bool req, bool def) async {
  try {
    await db.createBooleanAttribute(databaseId: dbId, collectionId: colId, key: key, xrequired: req, xdefault: def);
    print('   - عمود \$key مُضاف');
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    if (e.toString().contains('409')) return; 
    print('   ⚠️ فشل إضافة \$key');
  }
}

Future<void> _createDatetimeAttr(Databases db, String dbId, String colId, String key, bool req) async {
  try {
    await db.createDatetimeAttribute(databaseId: dbId, collectionId: colId, key: key, xrequired: req);
    print('   - عمود \$key مُضاف');
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    if (e.toString().contains('409')) return; 
    print('   ⚠️ فشل إضافة \$key');
  }
}
