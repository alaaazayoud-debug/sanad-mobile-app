import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.saveProfile(_nameController.text.trim());

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
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

                // أيقونة الشخص
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SanadTheme.success.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(SanadTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: SanadTheme.success,
                    size: 40,
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 32),

                Text(
                  'أهلاً بك في سند! 👋',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 10),

                Text(
                  'عرّفنا عن نفسك — اسمك أو اسم متجرك',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                const SizedBox(height: 48),

                // حقل الاسم
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'مثال: مؤسسة النور للتجارة',
                    prefixIcon: const Icon(
                      Icons.store_rounded,
                      color: SanadTheme.primaryBlue,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'أدخل اسمك أو اسم المتجر';
                    }
                    if (v.trim().length < 2) {
                      return 'الاسم قصير جدًا';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // زر الحفظ
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final isLoading = auth.state == AuthState.loading;
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _saveProfile,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          isLoading ? 'جاري الحفظ...' : 'ابدأ استخدام سند',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
