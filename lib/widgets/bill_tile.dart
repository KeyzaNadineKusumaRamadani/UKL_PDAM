import 'package:alirin/models/bill_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';


class BillTile extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit; // FIX: tambah onEdit

  const BillTile({super.key, required this.bill, this.onDelete, this.onEdit});

  Color get _statusColor {
    switch (bill.status) {
      case 'lunas': return AppColors.success;
      case 'menunggu': case 'menunggu_verif': return AppColors.warning;
      default: return AppColors.danger;
    }
  }
  Color get _statusBg {
    switch (bill.status) {
      case 'lunas': return AppColors.successLight;
      case 'menunggu': case 'menunggu_verif': return AppColors.warningLight;
      default: return AppColors.dangerLight;
    }
  }

  String get _initials {
    final name = bill.displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : '?';
  }

  static const List<Color> _colors = [
    Color(0xFF1565FF), Color(0xFF9C27B0), Color(0xFF00B8D4),
    Color(0xFF4CAF50), Color(0xFFFF9800),
  ];
  Color get _avatarColor => _colors[bill.customerId % _colors.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _avatarColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(child: Text(_initials,
                  style: TextStyle(color: _avatarColor, fontWeight: FontWeight.bold, fontSize: 13))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bill.displayName,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${bill.monthName} ${bill.year}  •  Meteran: ${bill.measurementNumber}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(bill.totalFormatted,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(bill.statusLabel,
                    style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text('Pemakaian: ${bill.usageValue.toStringAsFixed(0)} m³',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              // FIX: tombol edit (biru) di kiri tombol hapus
              if (onEdit != null) ...[
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 15),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 15),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}