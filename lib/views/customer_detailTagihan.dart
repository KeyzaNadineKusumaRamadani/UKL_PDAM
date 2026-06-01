import 'package:alirin/views/customer_StatusPembayaran.dart';
import 'package:alirin/views/customer_UploadPembayaran.dart';
import 'package:flutter/material.dart';
import '../models/bill_models.dart';
import '../models/payment_models.dart';
import '../service/api_service.dart';
import '../service/app_collors.dart';
import 'customer_dashboard_view.dart' show CustomerUploadBuktiPage;



class CustomerDetailTagihanPage extends StatefulWidget {
  final int billId;

  const CustomerDetailTagihanPage({
    super.key,
    required this.billId,
  });

  @override
  State<CustomerDetailTagihanPage> createState() =>
      _CustomerDetailTagihanPageState();
}

class _CustomerDetailTagihanPageState
    extends State<CustomerDetailTagihanPage> {
  BillModel? _bill;
  List<PaymentModel> _relatedPayments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final billData = await ApiService.getMyBillById(widget.billId);
    final paymentsData =
        await ApiService.getMyPayments(page: 1, quantity: 100);

    if (!mounted) return;

    if (billData == null) {
      setState(() {
        _error = 'Gagal memuat data tagihan';
        _loading = false;
      });
      return;
    }

    final bill = BillModel.fromJson(billData);
    final allPayments = (paymentsData['data'] as List)
        .map((e) => PaymentModel.fromJson(e))
        .toList();

    // Filter pembayaran yang terkait dengan tagihan ini
    final related = allPayments
        .where((p) => p.billId == widget.billId)
        .take(3)
        .toList();

    setState(() {
      _bill = bill;
      _relatedPayments = related;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bayar Tagihan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: _buildContent(),
                  ),
                ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.danger, size: 56),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    final b = _bill!;
    final period = '${AppColors.monthName(b.month)} ${b.year}';
    final statusColor = AppColors.statusColor(b.status);
    final statusBg    = AppColors.statusBgColor(b.status);
    final statusLabel = AppColors.statusLabel(b.status);
    final bool canPay = b.isUnpaid || b.isRejected;
    final bool isPending = b.isPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Detail Card ───────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period + status badge
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(period,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 14),

              // Jatuh tempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jatuh tempo',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  Text(
                    b.dueDate != null
                        ? AppColors.formatDate(b.dueDate)
                        : '${b.month}/${b.year}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: b.isOverdue ? AppColors.danger : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Total tagihan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total tagihan',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  Text(
                    AppColors.formatCurrency(b.totalBill ?? 0),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 14),

              // Pemakaian + meter
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pemakaian Air',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                            Text('${b.usageValue.toStringAsFixed(0)} m³',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.speed_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('No. Meter',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                            Text(
                              '#${b.measurementNumber.isNotEmpty ? b.measurementNumber : '-'}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Action Button ─────────────────────────────────────
        if (canPay)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomerUploadBuktiPage(
                      bill: b,
                      customer: null,
                    ),
                  ),
                );
                if (result == true && mounted) _load();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: b.isRejected
                    ? AppColors.danger
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                b.isRejected ? 'Bayar Ulang →' : 'Bayar sekarang →',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          )
        else if (isPending)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _relatedPayments.isNotEmpty
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CustomerStatusPembayaranPage(
                            paymentId: _relatedPayments.first.id,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Lihat Status',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text('Sudah Lunas ✓',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ],
            ),
          ),

        // ── Riwayat Pembayaran ────────────────────────────────
        if (_relatedPayments.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pembayaran',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const CustomerRiwayatPembayaranPageInline(
                              billId: -1),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(children: const [
                  Text('Semua',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary, size: 16),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._relatedPayments.map(_buildPaymentHistoryItem),
        ],
      ],
    );
  }

  Widget _buildPaymentHistoryItem(PaymentModel p) {
    final b = p.bill ?? _bill;
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (p.isPending) {
      statusColor = AppColors.warning;
      statusLabel = 'Menunggu Verifikasi';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (p.isPaid) {
      statusColor = AppColors.success;
      statusLabel = 'Lunas';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = AppColors.danger;
      statusLabel = 'Ditolak';
      statusIcon = Icons.cancel_rounded;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                CustomerStatusPembayaranPage(paymentId: p.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppColors.formatDate(p.createdAt),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppColors.formatCurrency(b?.totalBill ?? 0),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder untuk "Riwayat Tagihan" link di detail — akan mengarah ke
/// CustomerRiwayatPembayaranPage yang sebenarnya melalui named route
class CustomerRiwayatPembayaranPageInline extends StatelessWidget {
  final int billId;
  const CustomerRiwayatPembayaranPageInline({super.key, required this.billId});

  @override
  Widget build(BuildContext context) {
    // Redirect ke halaman riwayat pembayaran global
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const _RiwayatRedirect(),
        ),
      );
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _RiwayatRedirect extends StatelessWidget {
  const _RiwayatRedirect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Riwayat Pembayaran',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      body: const Center(
        child: Text('Lihat tab Bayar untuk riwayat lengkap',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}