import 'dart:math' show max;

import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';


class RevenueBarChart extends StatelessWidget {
  final List<PaymentModel> payments;

  const RevenueBarChart({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = {
      ...payments
          .where((p) => p.isVerified && p.year > 0)
          .map((p) => p.year),
      now.year,
    }.toList()..sort();

    return _RevenueBarChartStateful(
      payments: payments,
      availableYears: years,
      initialYear: now.year,
    );
  }
}

class _RevenueBarChartStateful extends StatefulWidget {
  final List<PaymentModel> payments;
  final List<int> availableYears;
  final int initialYear;

  const _RevenueBarChartStateful({
    required this.payments,
    required this.availableYears,
    required this.initialYear,
  });

  @override
  State<_RevenueBarChartStateful> createState() =>
      _RevenueBarChartStatefulState();
}

class _RevenueBarChartStatefulState
    extends State<_RevenueBarChartStateful> {
  late int _selectedYear;

  static const List<Color> _barColors = [
    Color(0xFF2563EB), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF06B6D4),
    Color(0xFFEC4899), Color(0xFF14B8A6), Color(0xFFF97316),
    Color(0xFF6366F1), Color(0xFF84CC16), Color(0xFFE11D48),
  ];

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
  }

  List<_MonthRevenue> _buildMonthlyData() {
    final revenueMap = {for (int m = 1; m <= 12; m++) m: 0.0};
    for (final p in widget.payments) {
      if (!p.isVerified) continue;
      if (p.year != _selectedYear) continue;
      if (p.month < 1 || p.month > 12) continue;
      revenueMap[p.month] = (revenueMap[p.month] ?? 0) + p.total;
    }
    return List.generate(
      12,
      (i) => _MonthRevenue(
        label: _monthNames[i + 1],
        total: revenueMap[i + 1] ?? 0,
      ),
    );
  }

  String _fmt(double val) {
    if (val >= 1000000) return 'Rp${(val / 1000000).toStringAsFixed(1)}jt';
    if (val >= 1000) return 'Rp${(val / 1000).toStringAsFixed(0)}rb';
    return 'Rp${val.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildMonthlyData();
    final maxVal = data.fold<double>(0, (p, m) => max(p, m.total));
    final totalRevenue = data.fold<double>(0, (s, m) => s + m.total);

    final ticks = [0.0, maxVal / 3, (maxVal * 2) / 3, maxVal];
    const double barAreaH = 130.0;
    const double totalChartH = 155.0;
    const double labelH = 18.0;

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
          // ── Header ──
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Pendapatan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tahun $_selectedYear',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol pilih tahun
              GestureDetector(
                onTap: () => _showYearPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_selectedYear',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    _fmt(totalRevenue),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Chart ──
          SizedBox(
            height: totalChartH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 52,
                  child: Stack(
                    children: List.generate(ticks.length, (i) {
                      final fraction =
                          maxVal == 0 ? 0.0 : ticks[i] / maxVal;
                      final topPx =
                          labelH + (1.0 - fraction) * barAreaH - 6;
                      return Positioned(
                        top: topPx,
                        right: 0,
                        child: Text(
                          _fmt(ticks[i]),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),

                // Bar area — scrollable horizontal untuk 12 bulan
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 420,
                      height: totalChartH,
                      child: Stack(
                        children: [
                          // Grid lines
                          ...List.generate(ticks.length, (i) {
                            final fraction =
                                maxVal == 0 ? 0.0 : ticks[i] / maxVal;
                            final topPx =
                                labelH + (1.0 - fraction) * barAreaH;
                            return Positioned(
                              top: topPx,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 1,
                                color: i == 0
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade100,
                              ),
                            );
                          }),

                          // Bars
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: List.generate(data.length, (i) {
                                final item = data[i];
                                final color =
                                    _barColors[i % _barColors.length];
                                final barH = maxVal > 0
                                    ? (item.total / maxVal) * barAreaH
                                    : 0.0;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: labelH,
                                          child: item.total > 0
                                              ? FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    _fmt(item.total),
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          height: barH,
                                          decoration: barH > 0
                                              ? BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                    top: Radius.circular(5),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // ── Legend ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(data.length, (i) {
                final color = _barColors[i % _barColors.length];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
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
                        data[i].label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Tahun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.availableYears.map((year) {
                final isSelected = year == _selectedYear;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedYear = year);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MonthRevenue {
  final String label;
  final double total;
  const _MonthRevenue({required this.label, required this.total});
}