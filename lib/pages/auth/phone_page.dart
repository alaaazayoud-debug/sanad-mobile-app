import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+963';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '$_countryCode${_phoneController.text.trim()}';
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(phone);

    if (!mounted) return;

    if (auth.state == AuthState.otpSent) {
      Navigator.of(context).pushNamed(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // أيقونة الهاتف
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SanadTheme.primaryBlue.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(SanadTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: SanadTheme.primaryBlue,
                    size: 40,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1)),

                const SizedBox(height: 32),

                // العنوان
                Text(
                  'أدخل رقم هاتفك',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 10),

                Text(
                  'بنرسل لك كود تحقق على هالرقم',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 48),

                // حقل الرقم
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      // كود الدولة
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: SanadTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(
                              SanadTheme.radiusMedium),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _countryCode,
                            dropdownColor: SanadTheme.surface,
                            style: GoogleFonts.inter(
                              color: SanadTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: '+963', child: Text('+963 🇸🇾')),
                              DropdownMenuItem(
                                  value: '+90', child: Text('+90 🇹🇷')),
                              DropdownMenuItem(
                                  value: '+971', child: Text('+971 🇦🇪')),
                              DropdownMenuItem(
                                  value: '+966', child: Text('+966 🇸🇦')),
                              DropdownMenuItem(
                                  value: '+962', child: Text('+962 🇯🇴')),
                              DropdownMenuItem(
                                  value: '+961', child: Text('+961 🇱🇧')),
                              DropdownMenuItem(
                                  value: '+20', child: Text('+20 🇪🇬')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _countryCode = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // رقم الهاتف
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.inter(
                            color: SanadTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: '9XX XXX XXX',
                            hintStyle: GoogleFonts.inter(
                              color: SanadTheme.textMuted,
                              fontSize: 18,
                              letterSpacing: 1.5,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'أدخل رقم الهاتف';
                            }
                            if (v.trim().length < 9) {
                              return 'الرقم قصير';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // زر المتابعة
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final isLoading = auth.state == AuthState.loading;
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SanadTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SanadTheme.radiusMedium),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'متابعة',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                const SizedBox(height: 20),

                // رسالة الخطأ
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage == null) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SanadTheme.error.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(SanadTheme.radiusSmall),
                      ),
                      child: Text(
                        auth.errorMessage!,
                        style: GoogleFonts.cairo(
                          color: SanadTheme.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
