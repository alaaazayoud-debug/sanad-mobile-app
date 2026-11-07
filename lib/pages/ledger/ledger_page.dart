import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/partnership_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/balance_bar.dart';
import '../../widgets/transaction_bubble.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late PartnershipModel _partnership;
  final _scrollController = ScrollController();
  bool _loaded = false; // نمنع إعادة التحميل عند الرجوع من صفحة أخرى

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _partnership =
          ModalRoute.of(context)!.settings.arguments as PartnershipModel;
      _loaded = true;
      // تحميل المعاملات مرة واحدة فقط
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = context.read<AuthProvider>().userId;
        context.read<LedgerProvider>().loadTransactions(_partnership.id, userId);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.userId;

    return Scaffold(
      backgroundColor: SanadTheme.background,
      appBar: AppBar(
        backgroundColor: SanadTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // أفاتار الشريك
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SanadTheme.primaryBlue, SanadTheme.primaryBlueLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  (_partnership.partnerName ?? '?')[0],
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partnership.partnerName ?? 'شريك',
                    style: GoogleFonts.cairo(
                      color: SanadTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _partnership.partnerPhone ?? '',
                    style: GoogleFonts.inter(
                      color: SanadTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // شريط الرصيد الثابت
          Consumer<LedgerProvider>(
            builder: (context, ledger, _) {
              return BalanceBar(
                balance: ledger.confirmedBalance,
                currency: _partnership.currency,
              );
            },
          ),

          // قائمة المعاملات
          Expanded(
            child: Consumer<LedgerProvider>(
              builder: (context, ledger, _) {
                if (ledger.isLoading && ledger.transactions.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          SanadTheme.primaryBlue),
                    ),
                  );
                }

                if (ledger.transactions.isEmpty) {
                  return _buildEmptyState();
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  itemCount: ledger.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = ledger.transactions[index];
                    final isMine = tx.createdBy == currentUserId;
                    final canConfirm = tx.canBeConfirmedBy(currentUserId);

                    return TransactionBubble(
                      transaction: tx,
                      isMine: isMine,
                      currency: _partnership.currency,
                      onConfirm: canConfirm
                          ? () async {
                              await ledger.confirmTransaction(
                                  tx.id, currentUserId);
                            }
                          : null,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 60 * index),
                          duration: 300.ms,
                        )
                        .slideY(begin: 0.05);
                  },
                );
              },
            ),
          ),

          // شريط الإجراءات السفلي
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: SanadTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر فاتورة
          Expanded(
            child: _ActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'فاتورة',
              color: SanadTheme.invoiceColor,
              onTap: () => _navigateToNewTransaction('invoice'),
            ),
          ),
          const SizedBox(width: 10),
          // زر دفعة
          Expanded(
            child: _ActionButton(
              icon: Icons.payments_rounded,
              label: 'دفعة',
              color: SanadTheme.paymentColor,
              onTap: () => _navigateToNewTransaction('payment'),
            ),
          ),
          const SizedBox(width: 10),
          // زر استرجاع
          Expanded(
            child: _ActionButton(
              icon: Icons.assignment_return_rounded,
              label: 'استرجاع',
              color: SanadTheme.returnColor,
              onTap: () => _navigateToNewTransaction('return'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNewTransaction(String type) {
    Navigator.of(context).pushNamed(
      AppRoutes.newTransaction,
      arguments: {
        'partnership': _partnership,
        'type': type,
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: SanadTheme.textMuted.withValues(alpha: 0.4),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاملات بعد',
            style: GoogleFonts.cairo(
              color: SanadTheme.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجّل أول فاتورة أو دفعة من الأسفل',
            style: GoogleFonts.cairo(
              color: SanadTheme.textMuted.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
