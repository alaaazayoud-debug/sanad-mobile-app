import 'package:dart_appwrite/dart_appwrite.dart';
import 'dart:io';

Future<void> main() async {
  final client = Client()
    ..setEndpoint('https://fra.cloud.appwrite.io/v1')
    ..setProject('6a8ab8ed003d63d5f766')
    ..setKey('standard_90fa6f4976bf04498ba21dcf3d6dfec0ee4f5243a5d76db2cd260b9051b9a0ef73903ca81ccf469cce3bd63efcc1a4dffcfd38f60947a1e81c072960d4e6b932ef65b19613f2736ddc677abe6a7f42f65606ad6ed799ffb24b6b1bf1d199e0abb6ae68a53ddba624a9ef89bc55e6f3032dd205666a8d26816357cebcb96a5201');

  final databases = Databases(client);

  // جلب الـ DB ID الفعلي
  final dbs = await databases.list();
  final dbId = dbs.databases.first.$id;
  print('Database ID: $dbId');

  // تحديث صلاحيات كل المجموعات — السماح لأي مستخدم مسجل بالقراءة والإنشاء
  final collections = ['users', 'partnerships', 'transactions'];
  
  for (final colId in collections) {
    try {
      await databases.updateCollection(
        databaseId: dbId,
        collectionId: colId,
        name: colId,
        documentSecurity: true,
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.users()),
          Permission.update(Role.users()),
          Permission.delete(Role.users()),
        ],
      );
      print('✅ تم تحديث صلاحيات $colId');
    } catch (e) {
      print('❌ خطأ في $colId: $e');
    }
  }

  print('🎉 تم تحديث كل الصلاحيات!');
  exit(0);
}
