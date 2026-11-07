import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(otp);

    if (!mounted) return;

    if (success && auth.state == AuthState.needsProfile) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.setupProfile);
    } else if (success && auth.state == AuthState.authenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 65,
      height: 65,
      textStyle: GoogleFonts.inter(
        color: SanadTheme.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: SanadTheme.surfaceLight,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(color: Colors.transparent, width: 2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: SanadTheme.surfaceLight,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(color: SanadTheme.primaryBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: SanadTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: SanadTheme.primaryBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(color: SanadTheme.primaryBlue, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: SanadTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(color: SanadTheme.error, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: SanadTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              // أيقونة القفل
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SanadTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(SanadTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: SanadTheme.accentGold,
                  size: 40,
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 32),

              // العنوان
              Text(
                'كود التحقق',
                style: GoogleFonts.cairo(
                  color: SanadTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 10),

              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Text(
                    'أدخل الكود المُرسل إلى\n${auth.phoneNumber ?? ""}',
                    style: GoogleFonts.cairo(
                      color: SanadTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 16),

              // تلميح الكود الثابت (للـ pilot)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: SanadTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(SanadTheme.radiusSmall),
                  border: Border.all(
                    color: SanadTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: SanadTheme.accentGold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'نسخة تجريبية — الكود: 0000',
                      style: GoogleFonts.cairo(
                        color: SanadTheme.accentGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 40),

              // Pinput
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final hasError = auth.errorMessage != null;
                      return Pinput(
                        controller: _otpController,
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme:
                            hasError ? errorPinTheme : submittedPinTheme,
                        errorPinTheme: errorPinTheme,
                        onCompleted: _verifyOtp,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        animationCurve: Curves.easeInOut,
                        animationDuration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // رسالة الخطأ
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.errorMessage == null) return const SizedBox();
                  return Text(
                    auth.errorMessage!,
                    style: GoogleFonts.cairo(
                      color: SanadTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().shake();
                },
              ),

              const SizedBox(height: 32),

              // Loading
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.state != AuthState.loading) {
                    return const SizedBox();
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          SanadTheme.primaryBlue),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
