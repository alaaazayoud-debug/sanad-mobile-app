import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/partners_provider.dart';
import 'providers/ledger_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // شريط الحالة يتناسب مع الوضع الفاتح
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PartnersProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
      ],
      child: const SanadApp(),
    ),
  );
}
