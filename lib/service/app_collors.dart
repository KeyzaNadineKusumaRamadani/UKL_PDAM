import 'package:flutter/material.dart';

// 📁 lib/service/app_collors.dart
// Alirin Design System — Water Utility Theme
// Warna sesuai spesifikasi:
//   primary  : #2563EB (biru)
//   success  : #059669 (hijau)
//   warning  : #F59E0B (kuning)
//   danger   : #EF4444 (merah)

class AppColors {
  static const Color accent = Color(0xFF10B981);
  // Repo colors
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCard2 = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0A000000);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color successLight = Color(0xFFD1FAE5);

  // ── Primary ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2563EB);
  static const Color primaryDark  = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // ── Status ──────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color danger  = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg     = Color(0xFFFFFFFF);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // ── Border ──────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);

  // ── Status helpers ───────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'LUNAS':
      case 'VERIFIED':
        return success;
      case 'PENDING':
        return warning;
      case 'UNPAID':
      case 'REJECTED':
        return danger;
      default:
        return textSecondary;
    }
  }

  static Color statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'LUNAS':
      case 'VERIFIED':
        return const Color(0xFFD1FAE5);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'UNPAID':
      case 'REJECTED':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'LUNAS':
        return 'Lunas';
      case 'VERIFIED':
        return 'Lunas';
      case 'PENDING':
        return 'Menunggu Verifikasi';
      case 'UNPAID':
        return 'Belum dibayar';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // ── Utility formatters ───────────────────────────────────────
  static const List<String> monthNames = [
    '',
    'Januari', 'Februari', 'Maret', 'April',
    'Mei', 'Juni', 'Juli', 'Agustus',
    'September', 'Oktober', 'November', 'Desember',
  ];

  static const List<String> monthNamesShort = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String monthName(int month) {
    return (month >= 1 && month <= 12) ? monthNames[month] : '-';
  }

  static String formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : num.tryParse(amount.toString()) ?? 0;
    final String str = val.toStringAsFixed(0);
    final StringBuffer result = StringBuffer('Rp ');
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day} ${monthNames[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${monthNamesShort[dt.month]} ${dt.year} $hh:$mm';
    } catch (_) {
      return dateStr;
    }
  }

  /// Contoh: "Januari 2022"
  static String formatMonthYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr).toLocal();
      return '${monthNames[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}