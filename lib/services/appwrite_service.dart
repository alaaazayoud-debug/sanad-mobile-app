import 'package:appwrite/appwrite.dart';
import '../config/constants.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Realtime realtime;

  factory AppwriteService() {
    return _instance;
  }

  AppwriteService._internal() {
    client = Client()
      ..setEndpoint(AppConstants.appwriteEndpoint)
      ..setProject(AppConstants.appwriteProjectId);

    account = Account(client);
    databases = Databases(client);
    realtime = Realtime(client);
  }
}
