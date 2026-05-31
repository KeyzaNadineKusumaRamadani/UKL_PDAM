import 'package:alirin/models/customer_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomerTile({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  String get _initials {
    final parts = customer.name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (customer.name.isNotEmpty) {
      return customer.name.substring(0, customer.name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '??';
  }

  static const List<Color> _avatarColors = [
    Color(0xFF1565FF),
    Color(0xFF9C27B0),
    Color(0xFF00B8D4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
  ];

  Color get _avatarColor => _avatarColors[customer.name.length % _avatarColors.length];

  // Tentukan status berdasarkan data (bisa dikembangkan)
  String get _statusLabel => customer.serviceName?.isNotEmpty == true ? 'Lunas' : 'Belum Bayar';
  Color get _statusColor {
    final s = _statusLabel;
    if (s == 'Lunas') return AppColors.success;
    if (s == 'Terlambat') return AppColors.danger;
    if (s == 'Baru') return AppColors.primary;
    return AppColors.danger;
  }
  Color get _statusBg {
    final s = _statusLabel;
    if (s == 'Lunas') return AppColors.successLight;
    if (s == 'Terlambat') return AppColors.dangerLight;
    if (s == 'Baru') return AppColors.primaryLight;
    return AppColors.dangerLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _avatarColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                  color: _avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'NIK: ${_maskNik(customer.customerNumber ?? '')} • ${customer.address.isNotEmpty ? _shortAddress(customer.address) : '-'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                bg: AppColors.primaryLight,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.delete_outline,
                color: AppColors.danger,
                bg: AppColors.dangerLight,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _maskNik(String nik) {
    if (nik.length <= 6) return nik;
    return '${nik.substring(0, 4)}${'•' * (nik.length - 7)}${nik.substring(nik.length - 3)}';
  }

  String _shortAddress(String addr) {
    final parts = addr.split(',');
    return parts.last.trim();
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}
