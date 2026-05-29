import 'package:alirin/controllers/bill_controllers.dart';
import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import '../widgets/bill_tile.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

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
    setState(() => _isLoading = true);
    await Future.wait([
      billController.fetchBills(),
      billController.fetchPayments(),
      customerController.fetchCustomers(),
    ]);
    setState(() => _isLoading = false);
  }

  void _showDeleteBillDialog(BillModel b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Hapus tagihan ${b.customerName} bulan ${b.monthName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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

  void _showVerifyDialog(PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✅ Verifikasi Pembayaran?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
            children: [
              const TextSpan(text: 'Konfirmasi bahwa bukti bayar '),
              TextSpan(
                text: p.customerName,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                  text:
                      ' sudah valid. Status tagihan akan berubah menjadi Lunas.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(context);
              final result = await billController.verifyPayment(p.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ??
                      'Pembayaran diverifikasi'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _load();
            },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(PaymentModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('❌ Tolak Pembayaran?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text(
          'Tolak pembayaran dari ${p.customerName}?',
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
              final result = await billController.rejectPayment(p.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(result['message'] ?? 'Pembayaran ditolak'),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _load();
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Buat'),
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
                  ),
                ],
              ),
            ),

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
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(text: 'Daftar Tagihan'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Verifikasi Bayar'),
                        if (billController.pendingPayments > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${billController.pendingPayments}',
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
                        // Tab 1: Daftar Tagihan
                        billController.bills.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long_outlined,
                                        size: 60,
                                        color: AppColors.textMuted),
                                    SizedBox(height: 12),
                                    Text('Belum ada tagihan',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 15)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount:
                                      billController.bills.length,
                                  itemBuilder: (_, i) {
                                    return BillTile(
                                      bill: billController.bills[i],
                                      onDelete: () => _showDeleteBillDialog(
                                          billController.bills[i]),
                                    );
                                  },
                                ),
                              ),

                        // Tab 2: Verifikasi Bayar
                        billController.payments.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.payment_outlined,
                                        size: 60,
                                        color: AppColors.textMuted),
                                    SizedBox(height: 12),
                                    Text('Belum ada pembayaran',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 15)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount:
                                      billController.payments.length,
                                  itemBuilder: (_, i) {
                                    final p =
                                        billController.payments[i];
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
    final isVerified =
        payment.status == 'lunas' || payment.status == 'verified';
    final isRejected = payment.status == 'ditolak';

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
                      payment.customerName,
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
          if (onVerify != null || onReject != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onVerify != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onVerify,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
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
                        padding: const EdgeInsets.symmetric(vertical: 9),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih customer terlebih dahulu'),
          backgroundColor: AppColors.danger,
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

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil dibuat!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal membuat tagihan'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = customerController.customers;
    final matchedServices = _selectedCustomer?.serviceId != null
        ? serviceController.services
            .where((s) => s.id == _selectedCustomer!.serviceId)
            .toList()
        : <dynamic>[];
    final service = matchedServices.isNotEmpty ? matchedServices.first : null;
    final usage = double.tryParse(_usageCtrl.text) ?? 0;
    final total = service != null ? usage * service.price : 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buat Tagihan Baru',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Pilih Customer
              const Text('Pilih Customer',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
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
                        child: Text(
                          '${c.name} (${c.username})',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCustomer = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
                                fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14),
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
                              onChanged: (v) => setState(
                                  () => _selectedMonth = v ?? 1),
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
                                fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14),
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
                                                color:
                                                    AppColors.textPrimary,
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
                hint: '12345',
                controller: _meterCtrl,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'No. Meteran wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Pemakaian (m³)',
                hint: '45',
                controller: _usageCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Pemakaian wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Total preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Tagihan',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    Text(
                      service != null
                          ? 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
                          : 'Pilih customer',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
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