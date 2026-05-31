import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _gantiPassword = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final admin = authController.adminData;
    _nameCtrl = TextEditingController(text: admin?.name ?? '');
    _phoneCtrl = TextEditingController(text: admin?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gantiPassword && _passwordCtrl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru minimal 4 karakter'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Build request body sesuai postman PATCH /admins/:id
    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    };
    if (_gantiPassword && _passwordCtrl.text.trim().isNotEmpty) {
      data['password'] = _passwordCtrl.text.trim();
    }

    // updateProfile di controller akan load ID otomatis jika belum ada
    final adminId = authController.adminData?.id ?? 0;
    final result = await authController.updateProfile(adminId, data);

    setState(() => _isLoading = false);

    if (!mounted) return;

    final msg = result['message']?.toString() ?? '';
    final berhasil = result['data'] != null ||
        result['success'] == true ||
        msg.toLowerCase().contains('updated') ||
        msg.toLowerCase().contains('berhasil') ||
        msg.toLowerCase().contains('success');

    if (berhasil) {
      // Refresh profil dari server
      await authController.loadAdminProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '❌ ${msg.isNotEmpty ? msg : 'Gagal memperbarui profil'}'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = authController.adminData;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
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
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Username readonly
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard2.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline,
                              color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              admin?.username ?? '-',
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('Readonly',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Username tidak dapat diubah',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Nama
                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Telepon
                CustomTextField(
                  label: 'No. Telepon',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (v) => v == null || v.isEmpty
                      ? 'No. Telepon wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Toggle ganti password
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _gantiPassword
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline,
                              color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ganti Password',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text('Aktifkan untuk mengubah password',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _gantiPassword,
                            onChanged: (v) => setState(() {
                              _gantiPassword = v;
                              if (!v) _passwordCtrl.clear();
                            }),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      if (_gantiPassword) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Password baru (min. 4 karakter)',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.key_outlined,
                                color: AppColors.textMuted, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: AppColors.bgCard2,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Simpan Perubahan',
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}