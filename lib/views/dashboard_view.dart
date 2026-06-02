import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/controllers/bill_controllers.dart';
import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/widgets/bar_chart.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  final void Function(int tabIndex)? onNavigate;
  const DashboardView({super.key, this.onNavigate});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      customerController.fetchCustomers(),
      billController.fetchBills(),
      billController.fetchPayments(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final admin = authController.adminData;

    final sortedCustomers = [...customerController.customers]
      ..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/User 02a.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                admin?.initials ?? 'AD',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Halo Selamat Datang 👋',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              admin?.name.isNotEmpty == true
                                  ? admin!.name
                                  : (admin?.username ?? 'Admin'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else ...[
                  // ── Stats Grid ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _StatCard(
                          label: 'Total Customer',
                          value: '${customerController.customers.length}',
                          sub: '↑ 12 Bulan ini',
                          subColor: AppColors.success,
                          color: AppColors.primary,
                          bgColor: AppColors.primaryLight,
                        ),
                        _StatCard(
                          label: 'Tagihan Belum Dibayar',
                          value: '${billController.unpaidBills}',
                          sub: 'Perlu diperhatikan',
                          subColor: AppColors.danger,
                          color: AppColors.danger,
                          bgColor: AppColors.dangerLight,
                        ),
                        _StatCard(
                          label: 'Tagihan bulan ini',
                          value: '${billController.totalBills}',
                          sub: 'Aktif',
                          subColor: AppColors.success,
                          color: AppColors.success,
                          bgColor: AppColors.successLight,
                        ),
                        _StatCard(
                          label: 'Menunggu Verifikasi',
                          value: '${billController.pendingPayments}',
                          sub: 'Bukti Pembayaran',
                          subColor: AppColors.warning,
                          color: AppColors.warning,
                          bgColor: AppColors.warningLight,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Grafik Pendapatan ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RevenueBarChart(
                      payments: billController.payments,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Aktivitas Terbaru ──
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (billController.payments.isEmpty &&
                      customerController.customers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada aktivitas',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Payments terbaru
                          ...billController.payments.take(3).map((p) {
                            final isPending = p.isPending;
                            final isVerified = p.isVerified;
                            return _ActivityTile(
                              title: isPending
                                  ? 'Pembayaran terbaru'
                                  : isVerified
                                      ? 'Pembayaran Terverifikasi'
                                      : 'Pembayaran Ditolak',
                              subtitle: p.customerName.isNotEmpty
                                  ? p.customerName
                                  : 'Customer',
                              time: '2 menit lalu',
                              status: isPending
                                  ? 'Pending'
                                  : isVerified
                                      ? 'Lunas'
                                      : 'Ditolak',
                              statusColor: isPending
                                  ? AppColors.warning
                                  : isVerified
                                      ? AppColors.success
                                      : AppColors.danger,
                              statusBg: isPending
                                  ? AppColors.warningLight
                                  : isVerified
                                      ? AppColors.successLight
                                      : AppColors.dangerLight,
                              icon: isPending
                                  ? Icons.notifications_outlined
                                  : isVerified
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                              iconBg: isPending
                                  ? AppColors.warningLight
                                  : isVerified
                                      ? AppColors.successLight
                                      : AppColors.dangerLight,
                              iconColor: isPending
                                  ? AppColors.warning
                                  : isVerified
                                      ? AppColors.success
                                      : AppColors.danger,
                              onTap: () => widget.onNavigate?.call(3),
                            );
                          }),

                          // Customer terbaru
                          ...sortedCustomers.take(3).map((c) {
                            return _ActivityTile(
                              title: 'Customer Baru Terdaftar',
                              subtitle: c.name,
                              time: 'Baru saja',
                              status: 'Baru',
                              statusColor: AppColors.primary,
                              statusBg: AppColors.primaryLight,
                              icon: Icons.person_add_outlined,
                              iconBg: AppColors.primaryLight,
                              iconColor: AppColors.primary,
                              onTap: () => widget.onNavigate?.call(2),
                            );
                          }),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color subColor;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: subColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Activity Tile ──
class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$subtitle • $time',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: onTap != null
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}