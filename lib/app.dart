import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'pages/splash_page.dart';
import 'pages/auth/phone_page.dart';
import 'pages/auth/otp_page.dart';
import 'pages/auth/setup_profile_page.dart';
import 'pages/home/home_page.dart';
import 'pages/ledger/ledger_page.dart';
import 'pages/ledger/new_transaction_page.dart';
import 'pages/profile/profile_page.dart';

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سند',
      debugShowCheckedModeBanner: false,
      theme: SanadTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // الاتجاه RTL افتراضي
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // الصفحة الأولى
      initialRoute: AppRoutes.splash,

      // Routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return _buildRoute(settings, const SplashPage());

          case AppRoutes.phone:
            return _buildRoute(settings, const PhonePage());

          case AppRoutes.otp:
            return _buildRoute(settings, const OtpPage());

          case AppRoutes.setupProfile:
            return _buildRoute(settings, const SetupProfilePage());

          case AppRoutes.home:
            return _buildRoute(settings, const HomePage());

          case AppRoutes.ledger:
            return _buildRoute(settings, const LedgerPage());

          case AppRoutes.newTransaction:
            return _buildRoute(settings, const NewTransactionPage());

          case AppRoutes.profile:
            return _buildRoute(settings, const ProfilePage());

          default:
            return _buildRoute(
              settings,
              Scaffold(
                backgroundColor: SanadTheme.background,
                body: Center(
                  child: Text(
                    'صفحة غير موجودة',
                    style: GoogleFonts.cairo(
                      color: SanadTheme.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  /// بناء route مع animation
  PageRoute _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.03, 0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
