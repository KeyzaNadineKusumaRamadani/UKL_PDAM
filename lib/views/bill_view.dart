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

  // ── Search & Filter State ──
  final _searchCtrl = TextEditingController();
  int? _filterMonth;   // null = semua bulan
  int? _filterYear;    // null = semua tahun
  String _searchQuery = '';

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String search = ''}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      customerController.fetchCustomers(),
      serviceController.fetchServices(),
    ]);
    await Future.wait([
      billController.fetchBills(search: search),
      billController.fetchPayments(),
    ]);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ── Filter bills client-side berdasarkan bulan/tahun + nama ──
  List<BillModel> get _filteredBills {
    return billController.bills.where((b) {
      final matchName = _searchQuery.isEmpty ||
          b.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.customerNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchMonth = _filterMonth == null || b.month == _filterMonth;
      final matchYear  = _filterYear  == null || b.year  == _filterYear;
      return matchName && matchMonth && matchYear;
    }).toList();
  }

  // ── Filter payments client-side ──
  List<PaymentModel> get _filteredPayments {
    return billController.payments.where((p) {
      final matchName = _searchQuery.isEmpty ||
          p.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchMonth = _filterMonth == null || p.month == _filterMonth;
      final matchYear  = _filterYear  == null || p.year  == _filterYear;
      return matchName && matchMonth && matchYear;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _filterMonth != null || _filterYear != null || _searchQuery.isNotEmpty;

  void _clearFilters() {
    setState(() {
      _filterMonth = null;
      _filterYear  = null;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  void _showDeleteBillDialog(BillModel b) {
    showDialog(
      context: context,
      builder: (_) => _DeleteBillDialog(bill: b, onDeleted: _load),
    );
  }

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
        .where((p) => p.isPending)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: ''),

            // ── Header: Judul + Tombol Buat ──
            Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kelola Tagihan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Buat',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await _showCreateBillSheet();
                          _load();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Search Bar ──
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      // Juga fetch dari API dengan search
                      if (v.length >= 2 || v.isEmpty) {
                        _load(search: v);
                      }
                    },
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari nama customer...',
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() => _searchQuery = '');
                                _searchCtrl.clear();
                                _load();
                              },
                              child: const Icon(Icons.close,
                                  color: AppColors.textMuted, size: 18),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Filter Bulan & Tahun ──
                  Row(
                    children: [
                      // Dropdown Bulan
                      Expanded(
                        child: _FilterDropdown(
                          icon: Icons.calendar_month_outlined,
                          hint: 'Semua Bulan',
                          value: _filterMonth != null
                              ? _months[_filterMonth! - 1]
                              : null,
                          onTap: () => _showMonthPicker(),
                          isActive: _filterMonth != null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dropdown Tahun
                      Expanded(
                        child: _FilterDropdown(
                          icon: Icons.date_range_outlined,
                          hint: 'Semua Tahun',
                          value:
                              _filterYear != null ? '$_filterYear' : null,
                          onTap: () => _showYearPicker(),
                          isActive: _filterYear != null,
                        ),
                      ),
                      // Tombol Reset filter (muncul kalau ada filter aktif)
                      if (_hasActiveFilter) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _clearFilters,
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.danger
                                      .withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.filter_alt_off,
                                color: AppColors.danger, size: 18),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // ── Info hasil filter ──
                  if (_hasActiveFilter && !_isLoading) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 13,
                            color: AppColors.primary.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          _tabCtrl.index == 0
                              ? '${_filteredBills.length} tagihan ditemukan'
                              : '${_filteredPayments.length} pembayaran ditemukan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── TabBar ──
                  Container(
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
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      onTap: (_) => setState(() {}),
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
                                    borderRadius:
                                        BorderRadius.circular(10),
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
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Konten Tab ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : TabBarView(
                      controller: _tabCtrl,
                      children: [
                        // ── Tab 1: Daftar Tagihan ──
                        _filteredBills.isEmpty
                            ? _EmptyState(
                                icon: Icons.receipt_long_outlined,
                                text: _hasActiveFilter
                                    ? 'Tidak ada tagihan\nyang sesuai filter'
                                    : 'Belum ada tagihan',
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: _filteredBills.length,
                                  itemBuilder: (_, i) => BillTile(
                                    bill: _filteredBills[i],
                                    onEdit: () => _showEditBillSheet(
                                        _filteredBills[i]),
                                    onDelete: () => _showDeleteBillDialog(
                                        _filteredBills[i]),
                                  ),
                                ),
                              ),

                        // ── Tab 2: Verifikasi Bayar ──
                        _filteredPayments.isEmpty
                            ? _EmptyState(
                                icon: Icons.payment_outlined,
                                text: _hasActiveFilter
                                    ? 'Tidak ada pembayaran\nyang sesuai filter'
                                    : 'Belum ada pembayaran masuk',
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: _filteredPayments.length,
                                  itemBuilder: (_, i) {
                                    final p = _filteredPayments[i];
                                    return _PaymentCard(
                                      payment: p,
                                      onVerify: p.isPending
                                          ? () => _showVerifyDialog(p)
                                          : null,
                                      onReject: p.isPending
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

  // ── Month Picker Bottom Sheet ──
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Pilih Bulan',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_filterMonth != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _filterMonth = null);
                      Navigator.pop(context);
                    },
                    child: const Text('Reset',
                        style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: List.generate(12, (i) {
              final isSelected = _filterMonth == i + 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _filterMonth = i + 1);
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border),
                  ),
                  child: Text(
                    _months[i],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Year Picker Bottom Sheet ──
  void _showYearPicker() {
    const years = [2024, 2025, 2026, 2027];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Pilih Tahun',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_filterYear != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _filterYear = null);
                      Navigator.pop(context);
                    },
                    child: const Text('Reset',
                        style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: years.map((y) {
                final isSelected = _filterYear == y;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _filterYear = y);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.bgCard2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$y',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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

// ── Komponen Filter Dropdown ──
class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final bool isActive;

  const _FilterDropdown({
    required this.icon,
    required this.hint,
    required this.value,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? AppColors.primary : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Dialog Verifikasi / Tolak ──
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
        (result['error'] == null &&
            result['message'] == null &&
            result['success'] == null);

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
        backgroundColor: berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (berhasil) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.isVerify ? '✅ Verifikasi Pembayaran?' : '❌ Tolak Pembayaran?',
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
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ],
            )
          : RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                children: [
                  const TextSpan(text: 'Konfirmasi pembayaran dari '),
                  TextSpan(
                    text: widget.payment.customerName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' sebesar ${widget.payment.totalFormatted}?\n\n'
                        'Status tagihan akan berubah menjadi '
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
                  backgroundColor:
                      widget.isVerify ? AppColors.success : AppColors.danger,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _action,
                child:
                    Text(widget.isVerify ? 'Verifikasi' : 'Tolak'),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt,
                    color: AppColors.textMuted, size: 28),
              ),
              const SizedBox(width: 14),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.monthName} ${payment.year}  •  ${payment.totalFormatted}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.success.withOpacity(0.15)
                      : isRejected
                          ? AppColors.danger.withOpacity(0.15)
                          : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isVerified ? 'Lunas' : isRejected ? 'Ditolak' : 'Pending',
                  style: TextStyle(
                    color: isVerified
                        ? AppColors.success
                        : isRejected
                            ? AppColors.danger
                            : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (isVerified)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_box, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text('Sudah diverifikasi',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),

          if (isRejected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: AppColors.danger, size: 20),
                  SizedBox(width: 8),
                  Text('Pembayaran ditolak',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),

          if (isPending) ...[
            Row(
              children: [
                if (onVerify != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onVerify,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('✅ Verifikasi',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                if (onVerify != null && onReject != null)
                  const SizedBox(width: 10),
                if (onReject != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onReject,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('❌ Tolak',
                              style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 14,
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
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
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

    final usage = double.tryParse(_usageCtrl.text.trim()) ?? 0;
    final services = serviceController.services
        .where((s) => s.id == _selectedCustomer!.serviceId)
        .toList();

    if (services.isNotEmpty) {
      final service = services.first;
      if (usage < service.minUsage || usage > service.maxUsage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Pemakaian harus antara ${service.minUsage.toInt()} - ${service.maxUsage.toInt()} m³ untuk layanan ${service.name}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final data = {
      'customer_id': _selectedCustomer!.id,
      'month': _selectedMonth,
      'year': _selectedYear,
      'measurement_number': _meterCtrl.text.trim(),
      'usage_value': usage,
    };

    final result = await billController.addBill(data);
    setState(() => _isLoading = false);
    if (!mounted) return;

    final msg = result['message']?.toString() ?? '';
    final berhasil = result['data'] != null ||
        result['success'] == true ||
        msg.toLowerCase().contains('created') ||
        msg.toLowerCase().contains('berhasil') ||
        msg.toLowerCase().contains('bill') ||
        msg.toLowerCase().contains('tagihan');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(berhasil
            ? '✅ Tagihan berhasil dibuat!'
            : '❌ ${msg.isNotEmpty ? msg : 'Gagal membuat tagihan'}'),
        backgroundColor: berhasil ? AppColors.success : AppColors.danger,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
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
              GestureDetector(
                onTap: () async {
                  final picked = await showModalBottomSheet<CustomerModel>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.bgCard,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => _CustomerSearchPicker(
                      customers: customerController.customers,
                      selected: _selectedCustomer,
                    ),
                  );
                  if (picked != null) setState(() => _selectedCustomer = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCustomer != null ? AppColors.primary : AppColors.border,
                      width: _selectedCustomer != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedCustomer != null ? Icons.person : Icons.person_search_outlined,
                        size: 18,
                        color: _selectedCustomer != null ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selectedCustomer != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _selectedCustomer!.username,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              )
                            : const Text(
                                'Ketuk untuk cari customer...',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                      ),
                      if (_selectedCustomer != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedCustomer = null),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),

              if (_selectedCustomer != null) ...[
                const SizedBox(height: 6),
                Builder(builder: (_) {
                  final services = serviceController.services
                      .where((s) => s.id == _selectedCustomer!.serviceId)
                      .toList();
                  if (services.isEmpty) return const SizedBox();
                  final s = services.first;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${s.name}: ${s.minUsage.toInt()} - ${s.maxUsage.toInt()} m³  •  Rp ${s.price.toInt()}/m³',
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],

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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'No. Meteran wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Pemakaian (m³)',
                hint: _selectedCustomer != null
                    ? () {
                        final services = serviceController.services
                            .where(
                                (s) => s.id == _selectedCustomer!.serviceId)
                            .toList();
                        if (services.isEmpty) return '45';
                        final s = services.first;
                        return '${s.minUsage.toInt()} - ${s.maxUsage.toInt()}';
                      }()
                    : '45',
                controller: _usageCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Pemakaian wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              StatefulBuilder(
                builder: (_, setInner) => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
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
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side:
                            const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Buat Tagihan',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Form Edit Tagihan ──
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
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _meterCtrl =
        TextEditingController(text: widget.bill.measurementNumber);
    _usageCtrl = TextEditingController(
        text: widget.bill.usageValue.toStringAsFixed(0));
    _selectedMonth = widget.bill.month.clamp(1, 12);
    _selectedYear = widget.bill.year;
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
        content: Text(berhasil
            ? '✅ Tagihan berhasil diupdate!'
            : '❌ ${msg.isNotEmpty ? msg : 'Gagal mengupdate tagihan'}'),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Edit Tagihan',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
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
                validator: (v) =>
                    v == null || v.isEmpty ? 'No. Meteran wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                label: 'Pemakaian (m³)',
                hint: '45',
                controller: _usageCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Pemakaian wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Simpan Perubahan',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──
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
          Icon(icon, size: 60, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ── Delete Bill Dialog ──
class _DeleteBillDialog extends StatefulWidget {
  final BillModel bill;
  final VoidCallback onDeleted;
  const _DeleteBillDialog({required this.bill, required this.onDeleted});

  @override
  State<_DeleteBillDialog> createState() => _DeleteBillDialogState();
}

class _DeleteBillDialogState extends State<_DeleteBillDialog> {
  bool _isDeleting = false;

  Future<void> _hapus() async {
    setState(() => _isDeleting = true);
    await billController.removeBill(widget.bill.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '✅ Tagihan ${widget.bill.customerName} bulan ${widget.bill.monthName} berhasil dihapus'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.dangerLight, shape: BoxShape.circle),
          child: const Icon(Icons.delete_outline,
              color: AppColors.danger, size: 20),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Hapus Tagihan?',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 16)),
        ),
      ]),
      content: _isDeleting
          ? const Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 12),
              Text('Menghapus tagihan...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ])
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                        children: [
                      const TextSpan(text: 'Hapus tagihan '),
                      TextSpan(
                          text:
                              '${widget.bill.customerName} — ${widget.bill.monthName} ${widget.bill.year}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold)),
                      const TextSpan(text: '?'),
                    ])),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.3))),
                  child: const Text(
                    '⚠️ Tagihan yang dihapus tidak dapat dikembalikan.',
                    style:
                        TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
              ],
            ),
      actions: _isDeleting
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
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0),
                onPressed: _hapus,
                child: const Text('Hapus',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
    );
  }
}

// ── Customer Search Picker ──
class _CustomerSearchPicker extends StatefulWidget {
  final List<CustomerModel> customers;
  final CustomerModel? selected;

  const _CustomerSearchPicker({
    required this.customers,
    this.selected,
  });

  @override
  State<_CustomerSearchPicker> createState() => _CustomerSearchPickerState();
}

class _CustomerSearchPickerState extends State<_CustomerSearchPicker> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerModel> get _filtered {
    if (_query.isEmpty) return widget.customers;
    final q = _query.toLowerCase();
    return widget.customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.username.toLowerCase().contains(q) ||
          (c.customerNumber ?? '').toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Pilih Customer',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.customers.length} customer',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari nama, username, NIK...',
                  hintStyle: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textMuted, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close,
                              color: AppColors.textMuted, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Hasil count
            if (_query.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  filtered.isEmpty
                      ? 'Tidak ada customer yang cocok'
                      : '${filtered.length} customer ditemukan',
                  style: TextStyle(
                    fontSize: 11,
                    color: filtered.isEmpty
                        ? AppColors.danger
                        : AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),

            // List customer
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.person_search,
                              size: 48,
                              color: AppColors.textMuted.withOpacity(0.4)),
                          const SizedBox(height: 10),
                          const Text(
                            'Customer tidak ditemukan',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.border),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final isSelected = widget.selected?.id == c.id;

                        // Warna avatar dari nama
                        final colors = [
                          const Color(0xFF2563EB),
                          const Color(0xFF059669),
                          const Color(0xFFF59E0B),
                          const Color(0xFF8B5CF6),
                          const Color(0xFFEF4444),
                          const Color(0xFF00B8D4),
                        ];
                        final avatarColor =
                            colors[c.name.length % colors.length];

                        final initials = () {
                          final parts = c.name.trim().split(' ');
                          if (parts.length >= 2) {
                            return '${parts[0][0]}${parts[1][0]}'
                                .toUpperCase();
                          }
                          return c.name
                              .substring(
                                  0,
                                  c.name.length >= 2 ? 2 : c.name.length)
                              .toUpperCase();
                        }();

                        return InkWell(
                          onTap: () => Navigator.pop(context, c),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: avatarColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: avatarColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.username}${c.serviceName != null && c.serviceName!.isNotEmpty ? ' • ${c.serviceName}' : ''}',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Centang kalau sudah dipilih
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}