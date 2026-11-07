import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadTheme.background,
      appBar: AppBar(
        backgroundColor: SanadTheme.surface,
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.cairo(
            color: SanadTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // الأفاتار
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        SanadTheme.primaryBlue,
                        SanadTheme.primaryBlueLight
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(SanadTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color:
                            SanadTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (user?.name ?? '?')[0],
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 20),

                Text(
                  user?.name ?? 'مستخدم',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 6),

                Text(
                  user?.phone ?? '',
                  style: GoogleFonts.inter(
                    color: SanadTheme.textMuted,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // معلومات
                _ProfileItem(
                  icon: Icons.phone_rounded,
                  label: 'رقم الهاتف',
                  value: user?.phone ?? '—',
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05),

                _ProfileItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'تاريخ الانضمام',
                  value: user?.createdAt != null
                      ? '${user!.createdAt.year}/${user.createdAt.month}/${user.createdAt.day}'
                      : '—',
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),

                _ProfileItem(
                  icon: Icons.info_outline_rounded,
                  label: 'الإصدار',
                  value: 'سند v0.1.0 — نسخة تجريبية',
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),

                const SizedBox(height: 40),

                // زر تسجيل الخروج
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: SanadTheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                SanadTheme.radiusMedium),
                          ),
                          title: Text(
                            'تسجيل خروج',
                            style: GoogleFonts.cairo(
                              color: SanadTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'متأكد تبي تسجّل خروج؟',
                            style: GoogleFonts.cairo(
                              color: SanadTheme.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(false),
                              child: Text(
                                'إلغاء',
                                style: GoogleFonts.cairo(
                                    color: SanadTheme.textMuted),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(true),
                              child: Text(
                                'خروج',
                                style: GoogleFonts.cairo(
                                    color: SanadTheme.error),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.phone,
                            (route) => false,
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: SanadTheme.error.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            SanadTheme.radiusMedium),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded,
                        color: SanadTheme.error, size: 20),
                    label: Text(
                      'تسجيل خروج',
                      style: GoogleFonts.cairo(
                        color: SanadTheme.error,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: SanadTheme.surface,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SanadTheme.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SanadTheme.radiusSmall),
            ),
            child: Icon(icon, color: SanadTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
