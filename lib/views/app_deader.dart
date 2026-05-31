import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final admin = authController.adminData;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar admin
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.25),
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
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Greeting + name
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
                        fontSize: 11,
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
                          fontSize: 10,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Judul halaman di tengah-kanan
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // Notif / actions
          if (actions != null) ...actions!
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.primary, size: 18),
            ),
        ],
      ),
    );
  }
}