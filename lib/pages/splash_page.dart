import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // محاكاة وقت التحميل
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // TODO: فحص حالة تسجيل الدخول من Provider
    Navigator.of(context).pushReplacementNamed(AppRoutes.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ══════════════════════════════════════════
            // شعار عصري وأنيق
            // ══════════════════════════════════════════
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SanadTheme.primaryBlue,
                    SanadTheme.primaryBlueLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: SanadTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الأيقونة الهندسية (كتاب / مصافحة)
                  Icon(
                    Icons.handshake_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 50,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: SanadTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0, 0),
                )
                .then()
                .shimmer(
                  duration: 1000.ms,
                  color: Colors.white.withValues(alpha: 0.2),
                ),

            const SizedBox(height: 32),

            // ══════════════════════════════════════════
            // اسم التطبيق
            // ══════════════════════════════════════════
            Text(
              'سَــنَــد',
              style: GoogleFonts.tajawal(
                color: SanadTheme.textPrimary,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // ══════════════════════════════════════════
            // الشعار اللفظي
            // ══════════════════════════════════════════
            Text(
              'دفتر الحسابات الرقمي بين الشركاء',
              style: GoogleFonts.tajawal(
                color: SanadTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
