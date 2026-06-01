import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/api_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import 'customer_dashboard_view.dart';

class CustomerStatusPembayaranPage extends StatefulWidget {
  final int paymentId;

  const CustomerStatusPembayaranPage({
    super.key,
    required this.paymentId,
  });

  @override
  State<CustomerStatusPembayaranPage> createState() => _CustomerStatusPembayaranPageState();
}

class _CustomerStatusPembayaranPageState extends State<CustomerStatusPembayaranPage> {
  bool _isLoading = true;
  PaymentModel? _payment;
  BillModel? _bill;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final paymentRes = await ApiService.getMyPaymentDetail(widget.paymentId);
    
    if (mounted) {
      setState(() {
        if (paymentRes != null && paymentRes['success'] == true) {
          _payment = PaymentModel.fromJson(paymentRes['data']);
          // Also fetch bills to find the corresponding bill
          ApiService.getMyBills().then((billsRes) {
            if (billsRes['success'] == true) {
              final bData = billsRes['data'] as List?;
              if (bData != null && mounted) {
                final bills = bData.map((e) => BillModel.fromJson(e)).toList();
                try {
                  _bill = bills.firstWhere((b) => b.id == _payment!.billId);
                } catch (_) {}
                setState(() => _isLoading = false);
              }
            } else {
              setState(() => _isLoading = false);
            }
          });
        } else {
          _isLoading = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_payment == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    String statusText = 'Belum Terverifikasi';
    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.hourglass_bottom;
    
    if (_payment!.isVerified) {
      statusText = 'Terverifikasi';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else if (_payment!.isRejected) {
      statusText = 'Ditolak';
      statusColor = AppColors.danger;
      statusIcon = Icons.cancel;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_empty, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              
              const Text('Menunggu Verifikasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Bukti pembayaran Anda sudah kami terima\ndan sedang diperiksa oleh admin.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 8),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.calendar_month, 'Periode', _bill != null ? '${_bill!.monthName} ${_bill!.year}' : '-'),
                    const Divider(height: 24),
                    _detailRow(Icons.water_drop_outlined, 'Pemakaian', _bill != null ? '${_bill!.usageValue} m³' : '-'),
                    const Divider(height: 24),
                    _detailRow(Icons.speed, 'Meter', _bill != null ? _bill!.measurementNumber : '-'),
                    const Divider(height: 24),
                    _detailRow(Icons.access_time, 'Dikirim', _payment!.createdAt ?? '-'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_bill?.totalFormatted ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_in_talk_outlined, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Hubungi admin jika lebih dari 24 jam belum terverifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerDashboardView()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat riwayat pembayaran', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.grey))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}