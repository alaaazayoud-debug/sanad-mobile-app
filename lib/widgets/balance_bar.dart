import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BalanceBar extends StatelessWidget {
  final double balance;
  final String currency;

  const BalanceBar({
    super.key,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isZero = balance == 0;
    final isOwed = balance < 0;
    final absBalance = balance.abs();

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isZero) {
      statusText = 'الحساب مصفّر';
      statusColor = SanadTheme.textMuted;
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (balance > 0) {
      // الرصيد موجب = له علينا (الشريك مَدِين لنا)
      statusText = 'له علينا';
      statusColor = SanadTheme.success;
      statusIcon = Icons.arrow_downward_rounded;
    } else {
      // الرصيد سالب = لنا عليه (نحن مَدينون للشريك)
      statusText = 'لنا عليه';
      statusColor = SanadTheme.error;
      statusIcon = Icons.arrow_upward_rounded;
    }

    final currencySymbol = currency == 'SYP' ? 'ل.س' : '\$';
    final formattedBalance = absBalance == absBalance.roundToDouble()
        ? absBalance.toStringAsFixed(0)
        : absBalance.toStringAsFixed(2);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SanadTheme.surface,
        borderRadius: BorderRadius.circular(SanadTheme.radiusLarge),
        border: Border.all(color: SanadTheme.border, width: 1),
        boxShadow: SanadTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الرصيد الحالي',
                style: GoogleFonts.tajawal(
                  color: SanadTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isZero 
                      ? SanadTheme.surfaceLight 
                      : statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SanadTheme.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.tajawal(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedBalance,
                style: GoogleFonts.inter(
                  color: isZero ? SanadTheme.textPrimary : statusColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1,
                ),
              ).animate(key: ValueKey(balance)).scale(
                duration: 400.ms, 
                curve: Curves.easeOutBack,
                begin: const Offset(0.9, 0.9),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  currencySymbol,
                  style: GoogleFonts.tajawal(
                    color: SanadTheme.textMuted,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
