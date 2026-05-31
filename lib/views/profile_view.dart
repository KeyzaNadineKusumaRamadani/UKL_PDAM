import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';

import 'login_view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    await authController.loadAdminProfile();
    if (mounted) setState(() => _isLoading = false);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar & Hapus Sesi?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: const Text(
          'Kamu akan keluar dari aplikasi dan sesi akan dihapus.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              authController.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
                (_) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = authController.adminData;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _loadProfile,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'PROFIL ADMIN',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ── Avatar dengan asset image ──
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/User 02a.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  // Fallback: inisial jika asset tidak ada
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        admin?.initials ?? 'AD',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Badge edit kecil
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nama
                      Text(
                        admin?.name.isNotEmpty == true
                            ? admin!.name
                            : (admin?.username ?? 'Admin PDAM'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Administrator PDAM',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Info tiles
                      _InfoCard(children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: admin?.username.isNotEmpty == true
                              ? admin!.username
                              : 'Tidak tersedia',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('Readonly',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          ),
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Nama',
                          value: admin?.name.isNotEmpty == true ? admin!.name : '-',
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'No. Telepon',
                          value: admin?.phone.isNotEmpty == true ? admin!.phone : '-',
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.shield_outlined,
                          label: 'Role',
                          value: admin?.role ?? 'ADMIN',
                          valueColor: AppColors.primary,
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Edit Profil
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Profil',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileView()),
                            );
                            if (changed == true && mounted) setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Refresh
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 16, color: AppColors.accent),
                          label: const Text('Refresh Profil',
                              style: TextStyle(color: AppColors.accent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _loadProfile,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Logout
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('🚪 Keluar & Hapus Sesi',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _logout,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                      color: valueColor ?? AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, color: AppColors.border, indent: 16, endIndent: 16);
  }
}