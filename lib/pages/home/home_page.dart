import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/partners_provider.dart';
import '../../widgets/partner_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<PartnersProvider>().loadPartnerships(auth.userId);
    });
  }

  void _showAddPartnerDialog() {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: SanadTheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SanadTheme.radiusLarge),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SanadTheme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'إضافة شريك جديد',
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // اسم الشريك
                TextFormField(
                  controller: nameController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    color: SanadTheme.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'اسم الشريك أو المتجر',
                    prefixIcon: Icon(Icons.person_rounded,
                        color: SanadTheme.primaryBlue),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'أدخل الاسم';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // رقم الهاتف
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.inter(
                      color: SanadTheme.textPrimary,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                    decoration: const InputDecoration(
                      hintText: '+963 9XX XXX XXX',
                      prefixIcon: Icon(Icons.phone_rounded,
                          color: SanadTheme.primaryBlue),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'أدخل الرقم';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final auth = context.read<AuthProvider>();
                      final partners = context.read<PartnersProvider>();
                      final success = await partners.addPartner(
                        auth.userId,
                        phoneController.text.trim(),
                        nameController.text.trim(),
                      );

                      if (success && ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    icon: const Icon(Icons.person_add_rounded, size: 20),
                    label: Text(
                      'إضافة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadTheme.background,
      appBar: AppBar(
        backgroundColor: SanadTheme.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SanadTheme.primaryBlue, SanadTheme.primaryBlueLight],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'س',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'سند',
              style: GoogleFonts.cairo(
                color: SanadTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded,
                color: SanadTheme.textSecondary),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Consumer<PartnersProvider>(
        builder: (context, partners, _) {
          if (partners.isLoading && partners.partnerships.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(SanadTheme.primaryBlue),
              ),
            );
          }

          if (partners.partnerships.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: partners.partnerships.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 82,
              color: SanadTheme.surfaceLight.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final partnership = partners.partnerships[index];
              final auth = context.read<AuthProvider>();

              return PartnerTile(
                partnership: partnership,
                currentUserId: auth.userId,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.ledger,
                    arguments: partnership,
                  );
                },
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 80 * index),
                    duration: 400.ms,
                  )
                  .slideX(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPartnerDialog,
        backgroundColor: SanadTheme.primaryBlue,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'شريك جديد',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: SanadTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SanadTheme.radiusLarge),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: SanadTheme.primaryBlue,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ما عندك شركاء بعد',
            style: GoogleFonts.cairo(
              color: SanadTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف شريكك التجاري الأول\nوابدأ بتسجيل الحسابات',
            style: GoogleFonts.cairo(
              color: SanadTheme.textMuted,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
