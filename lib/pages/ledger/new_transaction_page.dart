import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/partnership_model.dart';
import '../../models/transaction_model.dart';
import '../../models/invoice_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ledger_provider.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _smartInputController = TextEditingController();
  bool _isPaidImmediately = false;
  bool _isSubmitting = false;
  InvoiceInputMode _inputMode = InvoiceInputMode.structured;
  List<InvoiceItem> _items = [];
  late AnimationController _tabController;

  late PartnershipModel _partnership;
  late TransactionType _type;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // نبدأ بصنف واحد فارغ للفواتير النظامية
    _items = [
      InvoiceItem(name: '', quantity: 1, unitPrice: 0),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _partnership = args['partnership'] as PartnershipModel;
      final typeStr = args['type'] as String;
      switch (typeStr) {
        case 'invoice':
          _type = TransactionType.invoice;
          break;
        case 'payment':
          _type = TransactionType.payment;
          _inputMode = InvoiceInputMode.smart; // الدفعات دائماً smart
          break;
        case 'return':
          _type = TransactionType.returnTx;
          _inputMode = InvoiceInputMode.smart;
          break;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _smartInputController.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (_type) {
      case TransactionType.invoice:
        return SanadTheme.invoiceColor;
      case TransactionType.payment:
        return SanadTheme.paymentColor;
      case TransactionType.returnTx:
        return SanadTheme.returnColor;
    }
  }

  IconData get _typeIcon {
    switch (_type) {
      case TransactionType.invoice:
        return Icons.receipt_long_rounded;
      case TransactionType.payment:
        return Icons.payments_rounded;
      case TransactionType.returnTx:
        return Icons.assignment_return_rounded;
    }
  }

  String get _typeLabel {
    switch (_type) {
      case TransactionType.invoice:
        return 'فاتورة جديدة';
      case TransactionType.payment:
        return 'دفعة جديدة';
      case TransactionType.returnTx:
        return 'استرجاع جديد';
    }
  }

  String get _currencySymbol =>
      _partnership.currency == 'SYP' ? 'ل.س' : '\$';

  // ══════════════════════════════
  // حساب الإجمالي
  // ══════════════════════════════
  double get _totalAmount {
    if (_type != TransactionType.invoice) {
      // الدفعات والاسترجاعات: المبلغ من الـ smart input
      if (_items.isNotEmpty && _items.first.total > 0) {
        return _items.first.total;
      }
      // محاولة parse من النص الحر
      final parsed = _tryParseSmartInput();
      return parsed?.total ?? 0;
    }

    if (_inputMode == InvoiceInputMode.structured) {
      return _items.fold(0, (sum, item) => sum + item.total);
    } else {
      // smart mode — parse من النص
      final parsed = _tryParseSmartInput();
      return parsed?.total ?? 0;
    }
  }

  InvoiceItem? _tryParseSmartInput() {
    return InvoiceItem.tryParse(_smartInputController.text);
  }

  // ══════════════════════════════
  // إضافة / حذف صنف
  // ══════════════════════════════
  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(name: '', quantity: 1, unitPrice: 0));
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, InvoiceItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  // ══════════════════════════════
  // إرسال الفاتورة
  // ══════════════════════════════
  Future<void> _submit() async {
    if (_totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أدخل مبلغ أكبر من صفر',
              style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: SanadTheme.error,
        ),
      );
      return;
    }

    if (_type == TransactionType.invoice &&
        _inputMode == InvoiceInputMode.structured) {
      // تحقق من الأصناف
      final hasEmptyItems = _items.any(
        (item) => item.name.trim().isEmpty || item.unitPrice <= 0,
      );
      if (hasEmptyItems) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('أكمل بيانات جميع الأصناف',
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: SanadTheme.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final ledger = context.read<LedgerProvider>();

    // تجهيز الأصناف المرسلة
    List<InvoiceItem> finalItems = [];
    if (_type == TransactionType.invoice) {
      if (_inputMode == InvoiceInputMode.structured) {
        finalItems = _items.where((i) => i.name.isNotEmpty).toList();
      } else {
        final parsed = _tryParseSmartInput();
        if (parsed != null) finalItems = [parsed];
      }
    }

    // الوصف
    String? description;
    if (_type != TransactionType.invoice) {
      description = _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : _smartInputController.text.trim();
    }

    final success = await ledger.addTransaction(
      partnershipId: _partnership.id,
      createdBy: auth.userId,
      type: _type,
      amount: _totalAmount,
      description: description,
      items: finalItems,
      inputMode: _inputMode,
      isPaidImmediately: _isPaidImmediately,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadTheme.background,
      appBar: AppBar(
        backgroundColor: SanadTheme.surface,
        title: Text(
          _typeLabel,
          style: GoogleFonts.cairo(
            color: _typeColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ══════════════════════
              // Header
              // ══════════════════════
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مع ${_partnership.partnerName ?? "الشريك"}',
                      style: GoogleFonts.cairo(
                        color: SanadTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ══════════════════════
              // Toggle الوضع (للفواتير فقط)
              // ══════════════════════
              if (_type == TransactionType.invoice) ...[
                _buildModeToggle(),
                const SizedBox(height: 20),
              ],

              // ══════════════════════
              // محتوى الإدخال
              // ══════════════════════
              if (_type == TransactionType.invoice &&
                  _inputMode == InvoiceInputMode.structured)
                _buildStructuredInvoice()
              else
                _buildSmartInput(),

              const SizedBox(height: 20),

              // ══════════════════════
              // إجمالي مرئي
              // ══════════════════════
              _buildTotalCard(),

              const SizedBox(height: 16),

              // ══════════════════════
              // خيار مدفوعة فورًا
              // ══════════════════════
              if (_type == TransactionType.invoice)
                _buildPaidImmediatelyToggle(),

              const SizedBox(height: 24),

              // ══════════════════════
              // زر الإرسال
              // ══════════════════════
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _typeColor),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white),
                  label: Text(
                    _isSubmitting ? 'جاري الإرسال...' : 'تسجيل المعاملة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // Toggle بين الوضع الذكي والنظامي
  // ══════════════════════════════════════════
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SanadTheme.surfaceLight,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: '📋 نظامي',
            isSelected: _inputMode == InvoiceInputMode.structured,
            onTap: () => setState(
                () => _inputMode = InvoiceInputMode.structured),
          ),
          _ModeButton(
            label: '🧠 ذكي',
            isSelected: _inputMode == InvoiceInputMode.smart,
            onTap: () =>
                setState(() => _inputMode = InvoiceInputMode.smart),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // الوضع النظامي — جدول الأصناف
  // ══════════════════════════════════════════
  Widget _buildStructuredInvoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header الجدول
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: SanadTheme.surfaceLight,
            borderRadius: BorderRadius.circular(SanadTheme.radiusSmall),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text('الصنف',
                    style: GoogleFonts.cairo(
                        color: SanadTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right),
              ),
              Expanded(
                flex: 2,
                child: Text('الكمية',
                    style: GoogleFonts.cairo(
                        color: SanadTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 2,
                child: Text('السعر',
                    style: GoogleFonts.cairo(
                        color: SanadTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 2,
                child: Text('المجموع',
                    style: GoogleFonts.cairo(
                        color: SanadTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // الأصناف
        ...List.generate(_items.length, (index) {
          return _InvoiceItemRow(
            key: ValueKey(index),
            item: _items[index],
            currencySymbol: _currencySymbol,
            canDelete: _items.length > 1,
            onChanged: (item) => _updateItem(index, item),
            onDelete: () => _removeItem(index),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
        }),

        const SizedBox(height: 12),

        // زر إضافة صنف
        OutlinedButton.icon(
          onPressed: _addItem,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _typeColor.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(SanadTheme.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: Icon(Icons.add_rounded, color: _typeColor, size: 20),
          label: Text(
            'إضافة صنف',
            style: GoogleFonts.cairo(
              color: _typeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // الوضع الذكي — نص حر
  // ══════════════════════════════════════════
  Widget _buildSmartInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // مثال إرشادي
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: SanadTheme.accentGold.withValues(alpha: 0.08),
            borderRadius:
                BorderRadius.circular(SanadTheme.radiusSmall),
            border: Border.all(
              color: SanadTheme.accentGold.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💡 أمثلة:',
                style: GoogleFonts.cairo(
                  color: SanadTheme.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• 5 ابر ديستون × 15\n• سماعات JBL 2 × 50\n• 100 (للدفعات)',
                style: GoogleFonts.cairo(
                  color: SanadTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // حقل الإدخال
        TextFormField(
          controller: _smartInputController,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            color: SanadTheme.textPrimary,
            fontSize: 16,
          ),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: _type == TransactionType.invoice
                ? 'مثال: 5 ابر ديستون × 15'
                : 'مثال: دفعة أولى — 500',
            prefixIcon: const Icon(Icons.edit_rounded,
                color: SanadTheme.primaryBlue),
          ),
        ),

        // وصف إضافي للدفعات
        if (_type != TransactionType.invoice) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              color: SanadTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              hintText: 'وصف إضافي (اختياري)',
              prefixIcon: Icon(Icons.notes_rounded,
                  color: SanadTheme.primaryBlue),
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════
  // بطاقة الإجمالي
  // ══════════════════════════════════════════
  Widget _buildTotalCard() {
    final total = _totalAmount;
    final formattedTotal = total == total.roundToDouble()
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _typeColor.withValues(alpha: 0.15),
            _typeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(
          color: _typeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            'الإجمالي',
            style: GoogleFonts.cairo(
              color: SanadTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '$formattedTotal $_currencySymbol',
            style: GoogleFonts.inter(
              color: total > 0 ? _typeColor : SanadTheme.textMuted,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // Toggle مدفوعة فوراً
  // ══════════════════════════════════════════
  Widget _buildPaidImmediatelyToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: SanadTheme.surfaceLight,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
      ),
      child: SwitchListTile(
        value: _isPaidImmediately,
        onChanged: (v) => setState(() => _isPaidImmediately = v),
        activeThumbColor: SanadTheme.success,
        title: Text(
          'مدفوعة فورًا',
          style: GoogleFonts.cairo(
            color: SanadTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'الفاتورة والدفعة بخطوة واحدة',
          style: GoogleFonts.cairo(
            color: SanadTheme.textMuted,
            fontSize: 12,
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ══════════════════════════════════════════
// زر Toggle الوضع
// ══════════════════════════════════════════
class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? SanadTheme.primaryBlue : Colors.transparent,
            borderRadius:
                BorderRadius.circular(SanadTheme.radiusSmall),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected
                  ? Colors.white
                  : SanadTheme.textMuted,
              fontSize: 14,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// صف صنف واحد في الجدول
// ══════════════════════════════════════════
class _InvoiceItemRow extends StatefulWidget {
  final InvoiceItem item;
  final String currencySymbol;
  final bool canDelete;
  final ValueChanged<InvoiceItem> onChanged;
  final VoidCallback onDelete;

  const _InvoiceItemRow({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<_InvoiceItemRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.item.name.isEmpty ? '' : widget.item.name);
    _qtyCtrl = TextEditingController(
        text: widget.item.quantity == 1
            ? ''
            : widget.item.quantity.toStringAsFixed(0));
    _priceCtrl = TextEditingController(
        text: widget.item.unitPrice == 0
            ? ''
            : widget.item.unitPrice.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(InvoiceItem(
      name: _nameCtrl.text,
      quantity: double.tryParse(_qtyCtrl.text) ?? 1,
      unitPrice: double.tryParse(_priceCtrl.text) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(_qtyCtrl.text) ?? 1;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final total = qty * price;
    final totalStr = total == total.roundToDouble()
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SanadTheme.surface,
        borderRadius: BorderRadius.circular(SanadTheme.radiusMedium),
        border: Border.all(
          color: SanadTheme.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // اسم الصنف
          Expanded(
            flex: 4,
            child: TextField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              onChanged: (_) => _notify(),
              style: GoogleFonts.cairo(
                color: SanadTheme.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'اسم الصنف',
                hintStyle: GoogleFonts.cairo(
                  color: SanadTheme.textMuted,
                  fontSize: 12,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SanadTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: SanadTheme.surfaceLight,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // الكمية
          Expanded(
            flex: 2,
            child: TextField(
              controller: _qtyCtrl,
              onChanged: (_) {
                setState(() {});
                _notify();
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: SanadTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: GoogleFonts.inter(
                  color: SanadTheme.textMuted,
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SanadTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: SanadTheme.surfaceLight,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // السعر
          Expanded(
            flex: 2,
            child: TextField(
              controller: _priceCtrl,
              onChanged: (_) {
                setState(() {});
                _notify();
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: SanadTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.inter(
                  color: SanadTheme.textMuted,
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SanadTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: SanadTheme.surfaceLight,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // المجموع (للقراءة فقط)
          Expanded(
            flex: 2,
            child: Text(
              totalStr,
              style: GoogleFonts.inter(
                color: total > 0
                    ? SanadTheme.invoiceColor
                    : SanadTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // زر الحذف
          SizedBox(
            width: 32,
            child: widget.canDelete
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.remove_circle_rounded,
                      color: SanadTheme.error,
                      size: 20,
                    ),
                    onPressed: widget.onDelete,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
