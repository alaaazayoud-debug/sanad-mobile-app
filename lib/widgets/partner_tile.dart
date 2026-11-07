import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/partnership_model.dart';

class PartnerTile extends StatelessWidget {
  final PartnershipModel partnership;
  final String currentUserId;
  final VoidCallback onTap;

  const PartnerTile({
    super.key,
    required this.partnership,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final balance = partnership.balanceFor(currentUserId);
    final balanceColor = balance > 0
        ? SanadTheme.success
        : balance < 0
            ? SanadTheme.error
            : SanadTheme.textMuted;

    final balanceLabel = balance > 0
        ? 'لك'
        : balance < 0
            ? 'عليك'
            : 'متساوي';

    final absBalance = balance.abs();
    final formattedBalance = absBalance == absBalance.roundToDouble()
        ? absBalance.toStringAsFixed(0)
        : absBalance.toStringAsFixed(2);

    // إضافة فواصل الآلاف
    final parts = formattedBalance.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final displayBalance = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;

    final currencySymbol = partnership.currency == 'SYP' ? 'ل.س' : '\$';

    // الحرف الأول من اسم الشريك
    final initial = (partnership.partnerName ?? '?')[0];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // الأفاتار
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SanadTheme.primaryBlue,
                    SanadTheme.primaryBlueLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnership.partnerName ?? 'شريك',
                    style: GoogleFonts.cairo(
                      color: SanadTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    partnership.lastTransactionDescription ?? 'لا توجد معاملات بعد',
                    style: GoogleFonts.cairo(
                      color: SanadTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // الرصيد
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$displayBalance $currencySymbol',
                  style: GoogleFonts.inter(
                    color: balanceColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(SanadTheme.radiusSmall),
                  ),
                  child: Text(
                    balanceLabel,
                    style: GoogleFonts.cairo(
                      color: balanceColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
