import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../config/theme.dart';
import '../models/transaction_model.dart';

class TransactionBubble extends StatelessWidget {
  final TransactionModel transaction;
  final bool isMine;
  final String currency;
  final VoidCallback? onConfirm;

  const TransactionBubble({
    super.key,
    required this.transaction,
    required this.isMine,
    required this.currency,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = currency == 'SYP' ? 'ل.س' : '\$';
    final amount = transaction.amount;
    final formattedAmount = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
        
    final timeFormat = intl.DateFormat('hh:mm a', 'ar');
    final timeString = timeFormat.format(transaction.createdAt);

    // الألوان والأيقونات حسب النوع
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (transaction.type) {
      case TransactionType.invoice:
        typeColor = SanadTheme.invoiceColor;
        typeIcon = Icons.receipt_long_rounded;
        typeLabel = 'فاتورة';
        break;
      case TransactionType.payment:
        typeColor = SanadTheme.paymentColor;
        typeIcon = Icons.payments_rounded;
        typeLabel = 'دفعة';
        break;
      case TransactionType.returnTx:
        typeColor = SanadTheme.returnColor;
        typeIcon = Icons.assignment_return_rounded;
        typeLabel = 'استرجاع';
        break;
    }

    // إذا كانت بانتظار التأكيد نعطيها لون رمادي باهت
    if (transaction.isPending) {
      typeColor = SanadTheme.textMuted;
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        width: MediaQuery.of(context).size.width * 0.75, // عرض أوسع قليلاً للبطاقة
        decoration: BoxDecoration(
          color: SanadTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(SanadTheme.radiusMedium),
            topRight: const Radius.circular(SanadTheme.radiusMedium),
            bottomLeft: Radius.circular(isMine ? SanadTheme.radiusMedium : 0),
            bottomRight: Radius.circular(isMine ? 0 : SanadTheme.radiusMedium),
          ),
          border: Border.all(color: SanadTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ══════════════════════════════════════════
            // Header (نوع المعاملة + التاريخ)
            // ══════════════════════════════════════════
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(SanadTheme.radiusMedium),
                  topRight: const Radius.circular(SanadTheme.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Icon(typeIcon, color: typeColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    typeLabel,
                    style: GoogleFonts.tajawal(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeString,
                    style: GoogleFonts.inter(
                      color: SanadTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════
            // المحتوى (المبلغ + الوصف)
            // ══════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // المبلغ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedAmount,
                        style: GoogleFonts.inter(
                          color: SanadTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          currencySymbol,
                          style: GoogleFonts.tajawal(
                            color: SanadTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // الوصف / الأصناف
                  if (transaction.hasItems && transaction.type == TransactionType.invoice) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ...transaction.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: GoogleFonts.tajawal(
                                  color: SanadTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} × ${item.unitPrice.toStringAsFixed(item.unitPrice.truncateToDouble() == item.unitPrice ? 0 : 2)}',
                              style: GoogleFonts.inter(
                                color: SanadTheme.textMuted,
                                fontSize: 12,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      transaction.description!,
                      style: GoogleFonts.tajawal(
                        color: SanadTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ══════════════════════════════════════════
            // Footer (حالة التأكيد أو زر الموافقة)
            // ══════════════════════════════════════════
            if (transaction.isPending) ...[
              const Divider(height: 1),
              if (onConfirm != null && !isMine)
                // زر التأكيد (الطرف الثاني)
                InkWell(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, 
                            color: SanadTheme.primaryBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'تأكيد المعاملة',
                          style: GoogleFonts.tajawal(
                            color: SanadTheme.primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // بانتظار الشريك (صاحب المعاملة)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  color: SanadTheme.surfaceLight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SanadTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'بانتظار تأكيد الشريك',
                        style: GoogleFonts.tajawal(
                          color: SanadTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
