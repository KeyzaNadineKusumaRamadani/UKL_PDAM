import 'dart:math' show max;
 
import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/api_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/customer_UploadPembayaran.dart';
import 'package:alirin/views/customer_receipt.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
 
import 'edit_customer_profile_view.dart';
import 'login_view.dart';
 
class CustomerDashboardView extends StatefulWidget {
  const CustomerDashboardView({super.key});
 
  @override
  State<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}
 
class _CustomerDashboardViewState extends State<CustomerDashboardView> {
  int _currentIndex = 0;
  CustomerModel? _customer;
  List<BillModel> _bills = [];
  bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profileRes = await ApiService.getMyProfile();
    final billsRes = await ApiService.getMyBills();
 
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('customer_username') ?? '';
 
    if (mounted) {
      setState(() {
        if (profileRes['success'] == true) {
          final data = profileRes['data'] ?? profileRes;
          final map = data is Map<String, dynamic>
              ? Map<String, dynamic>.from(data)
              : Map<String, dynamic>.from(data);
 
          if ((map['username'] == null ||
                  map['username'].toString().trim().isEmpty) &&
              savedUsername.isNotEmpty) {
            map['username'] = savedUsername;
          }
 
          _customer = CustomerModel.fromJson(map);
        }
        if (billsRes['success'] == true) {
          final bData = billsRes['data'];
          if (bData is List) {
            _bills = bData
                .map((e) => BillModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
        _isLoading = false;
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final tabs = [
      _CustomerBerandaTab(
        customer: _customer,
        bills: _bills,
        isLoading: _isLoading,
      ),
      _CustomerTagihanTab(
        bills: _bills,
        isLoading: _isLoading,
        onRefresh: _loadData,
      ),
      _CustomerBayarTab(bills: _bills, isLoading: _isLoading),
      _CustomerProfileTab(
        customer: _customer,
        isLoading: _isLoading,
        onRefresh: _loadData,
      ),
    ];
 
    return Scaffold(
      backgroundColor: Colors.white,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Tagihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Bayar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
 
class _BillBarChart extends StatelessWidget {
  final List<BillModel> bills;
 
  const _BillBarChart({required this.bills});
 
  static const List<Color> _barColors = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];
 
  @override
  Widget build(BuildContext context) {
    final sorted = [...bills]
      ..sort((a, b) {
        final aDate = a.year * 100 + a.month;
        final bDate = b.year * 100 + b.month;
        return aDate.compareTo(bDate);
      });
    final data =
        sorted.length > 6 ? sorted.sublist(sorted.length - 6) : sorted;
 
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Belum ada data tagihan',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
 
    final maxVal = data.fold<double>(
      0,
      (prev, b) => max(prev, b.effectiveTotal),
    );
 
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Tagihan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '6 bulan terakhir',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 52,
                  height: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        List.generate(4, (i) {
                          final val = maxVal * (3 - i) / 3;
                          return Text(
                            _formatShort(val),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          );
                        })..add(
                          const Text(
                            '0',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (_) => Divider(
                            height: 0,
                            color: Colors.grey.shade100,
                            thickness: 1,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(data.length, (i) {
                          final bill = data[i];
                          final ratio = maxVal > 0
                              ? bill.effectiveTotal / maxVal
                              : 0.0;
                          final barH = (ratio * 130).clamp(4.0, 130.0);
                          final color = _barColors[i % _barColors.length];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatShort(bill.effectiveTotal),
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    height: barH,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(data.length, (i) {
              final color = _barColors[i % _barColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    data[i].monthName.substring(0, 3),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
 
  String _formatShort(double val) {
    if (val >= 1000000) return 'Rp${(val / 1000000).toStringAsFixed(1)}jt';
    if (val >= 1000) return 'Rp${(val / 1000).toStringAsFixed(0)}rb';
    return 'Rp${val.toInt()}';
  }
}
 
class _CustomerBerandaTab extends StatelessWidget {
  final CustomerModel? customer;
  final List<BillModel> bills;
  final bool isLoading;
 
  const _CustomerBerandaTab({
    this.customer,
    required this.bills,
    required this.isLoading,
  });
 
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final latestBill = bills.isNotEmpty ? bills.first : null;
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Halo',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        customer?.name ?? 'Nama customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'No. Pelanggan: ${customer?.customerNumber ?? '-'}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Customer',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 18,
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (latestBill != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tagihan terbaru',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${latestBill.monthName} ${latestBill.year}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            latestBill.totalFormatted,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: latestBill.isPaid
                                  ? Colors.black
                                  : AppColors.danger,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: latestBill.isPaid
                                ? AppColors.successLight
                                : latestBill.isPending
                                    ? AppColors.warningLight
                                    : AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            latestBill.statusLabel,
                            style: TextStyle(
                              color: latestBill.isPaid
                                  ? AppColors.success
                                  : latestBill.isPending
                                      ? AppColors.warning
                                      : AppColors.danger,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pemakaian',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${latestBill.usageValue} m³',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.speed, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Meter',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '#${latestBill.measurementNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!latestBill.isPaid)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerUploadBuktiPage(
                                bill: latestBill,
                                customer: customer,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bayar sekarang',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _BillBarChart(bills: bills),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Tagihan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Lihat semua >',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...bills.take(3).map((b) => _HistoryCard(bill: b)),
          ],
        ),
      ),
    );
  }
}
 
class _HistoryCard extends StatelessWidget {
  final BillModel bill;
  const _HistoryCard({required this.bill});
 
  @override
  Widget build(BuildContext context) {
    final isPaid = bill.isPaid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bill.monthName} ${bill.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Pemakaian: ${bill.usageValue} m³',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.successLight
                      : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? 'Lunas' : 'Belum bayar',
                  style: TextStyle(
                    color: isPaid ? AppColors.success : AppColors.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bill.totalFormatted,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
 
class _CustomerTagihanTab extends StatelessWidget {
  final List<BillModel> bills;
  final bool isLoading;
  final VoidCallback onRefresh;
 
  const _CustomerTagihanTab({
    required this.bills,
    required this.isLoading,
    required this.onRefresh,
  });
 
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final unpaid = bills.where((b) => b.isUnpaid || b.isPending).toList();
    double totalUnpaid = unpaid.fold(
      0,
      (sum, item) => sum + item.effectiveTotal,
    );
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tagihan Saya',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Kelola dan bayar tagihan air bulanan anda',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total belum dibayar',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Rp ${totalUnpaid.toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.danger,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rata-rata pemakaian',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '41,7 m³ / bulan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...bills.map((b) => _BillCardDetailed(bill: b)),
          ],
        ),
      ),
    );
  }
}
 
class _BillCardDetailed extends StatelessWidget {
  final BillModel bill;
  const _BillCardDetailed({required this.bill});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bill.isUnpaid ? AppColors.danger : Colors.grey[200]!,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bill.monthName} ${bill.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'No. Meteran: ${bill.measurementNumber}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bill.isPaid
                            ? AppColors.successLight
                            : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bill.statusLabel,
                        style: TextStyle(
                          color: bill.isPaid
                              ? AppColors.success
                              : AppColors.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bill.totalFormatted,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: bill.isPaid ? Colors.black : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pemakaian: ${bill.usageValue} m³',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildActionButton(BuildContext context) {
    if (bill.isUnpaid || bill.isRejected) {
      return SizedBox(
        height: 36,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerUploadBuktiPage(bill: bill),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: bill.isRejected
                ? AppColors.danger
                : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          label: Text(
            bill.isRejected ? 'Bayar Ulang' : 'Bayar sekarang',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    } else if (bill.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warning),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: AppColors.warning, size: 14),
            SizedBox(width: 6),
            Text(
              'Menunggu verifikasi',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      // ✅ Sudah lunas — tampilkan tombol Lihat Nota
      return GestureDetector(
        onTap: () => _bukaNotaDariBill(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_rounded,
                  color: AppColors.primary, size: 14),
              SizedBox(width: 6),
              Text(
                'Lihat Nota',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _bukaNotaDariBill(BuildContext context) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final res = await ApiService.getMyPayments(page: 1, quantity: 100);
      final allPayments = (res['data'] as List? ?? [])
          .map((e) => PaymentModel.fromJson(e))
          .toList();

      final payment = allPayments
          .where((p) => p.billId == bill.id && p.isVerified)
          .firstOrNull;

      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota tidak ditemukan'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerReceiptPage(
            payment: payment,
            bill: bill,
            customer: null,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat nota: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
 
class _CustomerBayarTab extends StatelessWidget {
  final List<BillModel> bills;
  final bool isLoading;
 
  const _CustomerBayarTab({required this.bills, required this.isLoading});
 
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final unpaidBills = bills.where((b) => b.isUnpaid || b.isRejected).toList();
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bayar Tagihan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Pilih tagihan yang ingin anda bayar',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (unpaidBills.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Tidak ada tagihan yang belum dibayar.'),
                ),
              )
            else
              ...unpaidBills.map((b) => _BillCardDetailed(bill: b)),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Riwayat Tagihan >',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Text(
              'Rekam jejak pembayaran anda',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ...bills
                .where((b) => b.isPaid || b.isPending)
                .map((b) => _PaymentHistoryCard(bill: b)),
          ],
        ),
      ),
    );
  }
}
 
class _PaymentHistoryCard extends StatelessWidget {
  final BillModel bill;
  const _PaymentHistoryCard({required this.bill});
 
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData iconData;
    String statusText;
 
    if (bill.isPending) {
      statusColor = AppColors.warning;
      iconData = Icons.access_time;
      statusText = 'Menunggu Verifikasi';
    } else if (bill.isPaid) {
      statusColor = AppColors.success;
      iconData = Icons.check;
      statusText = 'Lunas';
    } else {
      statusColor = AppColors.danger;
      iconData = Icons.close;
      statusText = 'Ditolak';
    }
 
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: statusColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bill.monthName} ${bill.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bill.totalFormatted,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Dikirim',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    bill.dueDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ✅ Tombol Lihat Nota hanya muncul kalau lunas
              if (bill.isPaid)
                GestureDetector(
                  onTap: () => _bukaNotaDariBill(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Lihat Nota',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _bukaNotaDariBill(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final res = await ApiService.getMyPayments(page: 1, quantity: 100);
      final allPayments = (res['data'] as List? ?? [])
          .map((e) => PaymentModel.fromJson(e))
          .toList();

      final payment = allPayments
          .where((p) => p.billId == bill.id && p.isVerified)
          .firstOrNull;

      if (!context.mounted) return;
      Navigator.pop(context);

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota tidak ditemukan'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerReceiptPage(
            payment: payment,
            bill: bill,
            customer: null,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat nota: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
 
class _CustomerProfileTab extends StatefulWidget {
  final CustomerModel? customer;
  final bool isLoading;
  final VoidCallback onRefresh;
 
  const _CustomerProfileTab({
    this.customer,
    required this.isLoading,
    required this.onRefresh,
  });
 
  @override
  State<_CustomerProfileTab> createState() => _CustomerProfileTabState();
}
 
class _CustomerProfileTabState extends State<_CustomerProfileTab> {
  ServiceModel? _service;
  bool _serviceLoading = false;
 
  @override
  void initState() {
    super.initState();
    _fetchService();
  }
 
  @override
  void didUpdateWidget(_CustomerProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer?.serviceId != widget.customer?.serviceId) {
      _fetchService();
    }
  }
 
  Future<void> _fetchService() async {
    final svcId = widget.customer?.serviceId;
    if (svcId == null) return;
    setState(() => _serviceLoading = true);
    final res = await ApiService.getServiceById(svcId);
    if (mounted) {
      setState(() {
        _serviceLoading = false;
        final data = res['data'] ?? res;
        if (data is Map<String, dynamic> &&
            (res['success'] == true || res['data'] != null)) {
          _service = ServiceModel.fromJson(data);
        }
      });
    }
  }
 
  CustomerModel? get customer => widget.customer;
  bool get isLoading => widget.isLoading;
  VoidCallback get onRefresh => widget.onRefresh;
 
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              customer?.name ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pelanggan Alirin sejak Jan 2022',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Customer',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),
                  _infoRow(
                    Icons.credit_card,
                    'No. Pelanggan (NIK)',
                    customer?.customerNumber ?? '-',
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.phone, 'No. Telepon', customer?.phone ?? '-'),
                  const SizedBox(height: 16),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Alamat',
                    customer?.address ?? '-',
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    Icons.person_outline,
                    'Username customer',
                    customer?.username ?? '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Layanan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),
                  _infoRowText(
                    'Jenis layanan',
                    _serviceLoading
                        ? 'Memuat...'
                        : (_service?.name ?? customer?.serviceName ?? '-'),
                  ),
                  if (_serviceLoading) ...[
                    const SizedBox(height: 12),
                    const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ] else if (_service != null) ...[
                    const SizedBox(height: 12),
                    _infoRowText(
                      'Min. Pemakaian',
                      '${_service!.minUsage.toStringAsFixed(0)} m³',
                    ),
                    const SizedBox(height: 12),
                    _infoRowText(
                      'Max. Pemakaian',
                      '${_service!.maxUsage.toStringAsFixed(0)} m³',
                    ),
                    const SizedBox(height: 12),
                    _infoRowText('Tarif', '${_service!.priceFormatted}/m³'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (customer != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditCustomerProfileView(customer: customer!),
                      ),
                    );
                    if (changed == true) onRefresh();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit Profil',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _infoRowText(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}