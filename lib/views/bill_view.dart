import 'package:alirin/controllers/bill_controllers.dart';
import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/app_deader.dart';
import 'package:flutter/material.dart';
import '../widgets/bill_tile.dart';

import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class BillView extends StatefulWidget {
  const BillView({super.key});

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      customerController.fetchCustomers(),
      serviceController.fetchServices(),
    ]);
    await Future.wait([
      billController.fetchBills(),
      billController.fetchPayments(),
    ]);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _showDeleteBillDialog(BillModel b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Hapus tagihan ${b.customerName} bulan ${b.monthName} ${b.year}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await billController.removeBill(b.id);
              _load();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // FIX: tambah _showEditBillSheet
  void _showEditBillSheet(BillModel b) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditBillSheet(bill: b),
    );
    _load();
  }

  void _showVerifyDialog(PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => _VerifyDialog(
        payment: p,
        onDone: () => _load(),
        isVerify: true,
      ),
    );
  }

  void _showRejectDialog(PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => _VerifyDialog(
        payment: p,
        onDone: () => _load(),
        isVerify: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = billController.payments
        .where((p) => p.status == 'pending' || p.status == 'menunggu')
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: ''),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kelola Tagihan',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: () async {
                      await _showCreateBillSheet();
                      _load();
                    },
                    child: const Text('Buat', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  const Tab(text: 'Daftar Tagihan'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Verifikasi Bayar'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : TabBarView(
                      controller: _tabCtrl,
                      children: [
                        // ── Tab 1: Daftar Tagihan ──
                        billController.bills.isEmpty
                            ? const _EmptyState(
                                icon: Icons.receipt_long_outlined,
                                text: 'Belum ada tagihan')
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: billController.bills.length,
                                  itemBuilder: (_, i) => BillTile(
                                    bill: billController.bills[i],
                                    // FIX: sambungkan onEdit
                                    onEdit: () => _showEditBillSheet(
                                        billController.bills[i]),
                                    onDelete: () => _showDeleteBillDialog(
                                        billController.bills[i]),
                                  ),
                                ),
                              ),

                        // ── Tab 2: Verifikasi Bayar ──
                        billController.payments.isEmpty
                            ? const _EmptyState(
                                icon: Icons.payment_outlined,
                                text: 'Belum ada pembayaran masuk')
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount:
                                      billController.payments.length,
                                  itemBuilder: (_, i) {
                                    final p = billController.payments[i];
                                    final isPending =
                                        p.status == 'pending' ||
                                            p.status == 'menunggu';
                                    return _PaymentCard(
                                      payment: p,
                                      onVerify: isPending
                                          ? () => _showVerifyDialog(p)
                                          : null,
                                      onReject: isPending
                                          ? () => _showRejectDialog(p)
                                          : null,
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateBillSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreateBillSheet(),
    );
  }
}

// ── Dialog Verifikasi / Tolak dengan loading ──
class _VerifyDialog extends StatefulWidget {
  final PaymentModel payment;
  final VoidCallback onDone;
  final bool isVerify;

  const _VerifyDialog({
    required this.payment,
    required this.onDone,
    required this.isVerify,
  });

  @override
  State<_VerifyDialog> createState() => _VerifyDialogState();
}

class _VerifyDialogState extends State<_VerifyDialog> {
  bool _loading = false;

  Future<void> _action() async {
    setState(() => _loading = true);

    final result = widget.isVerify
        ? await billController.verifyPayment(widget.payment.id)
        : await billController.rejectPayment(widget.payment.id);

    if (!mounted) return;
    setState(() => _loading = false);

    final msg = result['message']?.toString() ?? '';
    final berhasil = result['success'] == true ||
        result['data'] != null ||
        msg.toLowerCase().contains('success') ||
        msg.toLowerCase().contains('verif') ||
        msg.toLowerCase().contains('berhasil') ||
        msg.toLowerCase().contains('payment') ||
        (result['error'] == null && result['message'] == null && result['success'] == null);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? widget.isVerify
                  ? '✅ Pembayaran ${widget.payment.customerName} berhasil diverifikasi'
                  : '✅ Pembayaran ${widget.payment.customerName} berhasil ditolak'
              : '❌ ${msg.isNotEmpty ? msg : 'Gagal memproses pembayaran'}',
        ),
        backgroundColor:
            berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (berhasil) {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.isVerify
            ? '✅ Verifikasi Pembayaran?'
            : '❌ Tolak Pembayaran?',
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      content: _loading
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 14),
                Text('Memproses...',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            )
          : RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                children: [
                  const TextSpan(
                      text: 'Konfirmasi pembayaran dari '),
                  TextSpan(
                    text: widget.payment.customerName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' sebesar ${widget.payment.totalFormatted}?\n\nStatus tagihan akan berubah menjadi '
                        '${widget.isVerify ? 'Lunas' : 'Belum Bayar'}.',
                  ),
                ],
              ),
            ),
      actions: _loading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isVerify
                      ? AppColors.success
                      : AppColors.danger,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _action,
                child: Text(widget.isVerify ? 'Verifikasi' : 'Tolak'),
              ),
            ],
    );
  }
}

// ── Payment Card ──
class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;

  const _PaymentCard({
    required this.payment,
    this.onVerify,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = payment.isVerified;
    final isRejected = payment.isRejected;
    final isPending = payment.isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt,
                    color: AppColors.textMuted, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.customerName.isNotEmpty
                          ? payment.customerName
                          : 'Customer',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    Text(
                      '${payment.monthName} ${payment.year}  •  ${payment.totalFormatted}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.success.withOpacity(0.15)
                      : isRejected
                          ? AppColors.danger.withOpacity(0.15)
                          : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isVerified
                      ? 'Lunas'
                      : isRejected
                          ? 'Ditolak'
                          : 'Pending',
                  style: TextStyle(
                    color: isVerified
                        ? AppColors.success
                        : isRejected
                            ? AppColors.danger
                            : AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onVerify != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onVerify,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color:
                              AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('✅ Verifikasi',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                if (onVerify != null && onReject != null)
                  const SizedBox(width: 8),
                if (onReject != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onReject,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('❌ Tolak',
                              style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Form Buat Tagihan ──
class _CreateBillSheet extends StatefulWidget {
  const _CreateBillSheet();

  @override
  State<_CreateBillSheet> createState() => _CreateBillSheetState();
}

class _CreateBillSheetState extends State<_CreateBillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _meterCtrl = TextEditingController();
  final _usageCtrl = TextEditingController();
  CustomerModel? _selectedCustomer;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void dispose() {
    _meterCtrl.dispose();
    _usageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih customer terlebih dahulu'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'customer_id': _selectedCustomer!.id,
      'month': _selectedMonth,
      'year': _selectedYear,
      'measurement_number': _meterCtrl.text.trim(),
      'usage_value': double.tryParse(_usageCtrl.text.trim()) ?? 0,
    };

    final result = await billController.addBill(data);
    setState(() => _isLoading = false);

    if (!mounted) return;

    final msg = result['message']?.toString() ?? '';
    final berhasil = result['data'] != null ||
        result['success'] == true ||
        msg.toLowerCase().contains('created') ||
        msg.toLowerCase().contains('berhasil');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? '✅ Tagihan berhasil dibuat!'
              : '❌ ${msg.isNotEmpty ? msg : 'Gagal membuat tagihan'}',
        ),
        backgroundColor:
            berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (berhasil) Navigator.pop(context);
  }

  double get _previewTotal {
    final usage = double.tryParse(_usageCtrl.text) ?? 0;
    if (_selectedCustomer?.serviceId == null) return 0;
    final services = serviceController.services
        .where((s) => s.id == _selectedCustomer!.serviceId)
        .toList();
    if (services.isEmpty) return 0;
    return usage * services.first.price;
  }

  String _formatRupiah(double val) {
    return 'Rp ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final customers = customerController.customers;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Buat Tagihan Baru',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('Pilih Customer',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CustomerModel>(
                    isExpanded: true,
                    value: _selectedCustomer,
                    dropdownColor: AppColors.bgCard,
                    hint: const Text('Pilih customer...',
                        style: TextStyle(color: AppColors.textMuted)),
                    items: customers.map((c) {
                      return DropdownMenuItem<CustomerModel>(
                        value: c,
                        child: Text('${c.name} (${c.username})',
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCustomer = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bulan',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedMonth,
                              dropdownColor: AppColors.bgCard,
                              items: List.generate(12, (i) {
                                return DropdownMenuItem<int>(
                                  value: i + 1,
                                  child: Text(_months[i],
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13)),
                                );
                              }),
                              onChanged: (v) =>
                                  setState(() => _selectedMonth = v ?? 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tahun',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedYear,
                              dropdownColor: AppColors.bgCard,
                              items: [2024, 2025, 2026, 2027]
                                  .map((y) => DropdownMenuItem<int>(
                                        value: y,
                                        child: Text('$y',
                                            style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v ?? 2026),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'No. Meteran',
                hint: '30041',
                controller: _meterCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'No. Meteran wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Pemakaian (m³)',
                hint: '45',
                controller: _usageCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty
                    ? 'Pemakaian wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              StatefulBuilder(
                builder: (_, setInner) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Customer',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                          Text(_selectedCustomer?.name ?? '-',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Tagihan',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            _selectedCustomer != null
                                ? _formatRupiah(_previewTotal)
                                : 'Pilih customer dulu',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Buat Tagihan',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FIX: Form Edit Tagihan ──
class _EditBillSheet extends StatefulWidget {
  final BillModel bill;
  const _EditBillSheet({required this.bill});

  @override
  State<_EditBillSheet> createState() => _EditBillSheetState();
}

class _EditBillSheetState extends State<_EditBillSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _meterCtrl;
  late TextEditingController _usageCtrl;
  late int _selectedMonth;
  late int _selectedYear;
  bool _isLoading = false;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill dengan data tagihan yang ada
    _meterCtrl = TextEditingController(text: widget.bill.measurementNumber);
    _usageCtrl = TextEditingController(
        text: widget.bill.usageValue.toStringAsFixed(0));
    _selectedMonth = widget.bill.month.clamp(1, 12);
    _selectedYear = widget.bill.year;
    // Pastikan tahun ada di list
    if (![2024, 2025, 2026, 2027].contains(_selectedYear)) {
      _selectedYear = 2026;
    }
  }

  @override
  void dispose() {
    _meterCtrl.dispose();
    _usageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'month': _selectedMonth,
      'year': _selectedYear,
      'measurement_number': _meterCtrl.text.trim(),
      'usage_value': double.tryParse(_usageCtrl.text.trim()) ?? 0,
    };

    final result = await billController.editBill(widget.bill.id, data);
    setState(() => _isLoading = false);

    if (!mounted) return;

    final msg = result['message']?.toString() ?? '';
    final berhasil = result['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? '✅ Tagihan berhasil diupdate!'
              : '❌ ${msg.isNotEmpty ? msg : 'Gagal mengupdate tagihan'}',
        ),
        backgroundColor: berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (berhasil) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text('Edit Tagihan',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  // Info nama customer (readonly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.bill.displayName,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bulan & Tahun
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bulan',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedMonth,
                              dropdownColor: AppColors.bgCard,
                              items: List.generate(12, (i) {
                                return DropdownMenuItem<int>(
                                  value: i + 1,
                                  child: Text(_months[i],
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13)),
                                );
                              }),
                              onChanged: (v) =>
                                  setState(() => _selectedMonth = v ?? 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tahun',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedYear,
                              dropdownColor: AppColors.bgCard,
                              items: [2024, 2025, 2026, 2027]
                                  .map((y) => DropdownMenuItem<int>(
                                        value: y,
                                        child: Text('$y',
                                            style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13)),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v ?? 2026),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'No. Meteran',
                hint: '30041',
                controller: _meterCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'No. Meteran wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Pemakaian (m³)',
                hint: '45',
                controller: _usageCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty
                    ? 'Pemakaian wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Simpan Perubahan',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(text,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 15)),
        ],
      ),
    );
  }
}