import 'package:alirin/views/customer_StatusPembayaran.dart';
import 'package:flutter/material.dart';
import '../models/payment_models.dart';
import '../service/api_service.dart';
import '../service/app_collors.dart';

// 📁 lib/views/customer_riwayat_pembayaran_page.dart
// Screen 8 — Riwayat Pembayaran

class CustomerRiwayatPembayaranPage extends StatefulWidget {
  const CustomerRiwayatPembayaranPage({super.key});

  @override
  State<CustomerRiwayatPembayaranPage> createState() =>
      _CustomerRiwayatPembayaranPageState();
}

class _CustomerRiwayatPembayaranPageState
    extends State<CustomerRiwayatPembayaranPage> {
  List<PaymentModel> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result =
        await ApiService.getMyPayments(page: 1, quantity: 100);
    if (!mounted) return;
    setState(() {
      _payments = (result['data'] as List)
          .map((e) => PaymentModel.fromJson(e))
          .toList();
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
          'Riwayat Pembayaran',
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
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: _payments.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: _payments.length,
                      itemBuilder: (_, i) =>
                          _buildPaymentCard(_payments[i]),
                    ),
            ),
    );
  }

  Widget _buildEmpty() => ListView(
        children: const [
          SizedBox(height: 120),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  color: AppColors.textSecondary, size: 64),
              SizedBox(height: 16),
              Text('Belum ada riwayat pembayaran',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ],
      );

  Widget _buildPaymentCard(PaymentModel p) {
    final b = p.bill;
    final period =
        b != null ? '${AppColors.monthName(b.month)} ${b.year}' : '-';

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (p.isPending) {
      statusColor = AppColors.warning;
      statusLabel = 'Menunggu';
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
            builder: (_) => CustomerStatusPembayaranPage(paymentId: p.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Status icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pembayaran $period',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    AppColors.formatDate(p.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppColors.formatCurrency(b?.totalBill ?? 0),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
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