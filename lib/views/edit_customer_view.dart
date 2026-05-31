import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EditCustomerView extends StatefulWidget {
  final CustomerModel customer;

  const EditCustomerView({super.key, required this.customer});

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _gantiPassword = false;
  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];
  bool _servicesLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer.name);
    _phoneCtrl = TextEditingController(text: widget.customer.phone);
    _addressCtrl = TextEditingController(text: widget.customer.address);
    _loadServices();
  }

  Future<void> _loadServices() async {
    // Pakai data yang sudah ada dulu jika tersedia
    if (serviceController.services.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _services = serviceController.services;
        _servicesLoaded = true;
        _matchSelectedService();
      });
      return;
    }

    // Fetch dari API
    await serviceController.fetchServices();

    if (!mounted) return; // Cek mounted sebelum setState
    setState(() {
      _services = serviceController.services;
      _servicesLoaded = true;
      _matchSelectedService();
    });
  }

  void _matchSelectedService() {
    if (widget.customer.serviceId != null && _services.isNotEmpty) {
      final matches = _services
          .where((s) => s.id == widget.customer.serviceId)
          .toList();
      if (matches.isNotEmpty) {
        _selectedService = matches.first;
      }
    }
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

    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      if (_selectedService != null) 'service_id': _selectedService!.id,
      if (_gantiPassword && _passwordCtrl.text.trim().isNotEmpty)
        'password': _passwordCtrl.text.trim(),
    };

    final result = await customerController.editCustomer(
        widget.customer.id, data);

    if (!mounted) return; // Cek mounted setelah async
    setState(() => _isLoading = false);

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Customer berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal update customer'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Customer',
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
                // Username readonly
                _ReadonlyField(
                  label: 'Username',
                  value: widget.customer.username.isNotEmpty
                      ? widget.customer.username
                      : '-',
                  icon: Icons.person_outline,
                  note: 'Username tidak dapat diubah',
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),

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

                CustomTextField(
                  label: 'Alamat',
                  controller: _addressCtrl,
                  maxLines: 2,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
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
                                Text('Kosongkan jika tidak ingin ganti',
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
                            hintText: 'Password baru...',
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
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
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
                const SizedBox(height: 14),

                // Dropdown Layanan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Layanan',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: !_servicesLoaded
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Memuat layanan...',
                                      style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13)),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<ServiceModel>(
                                isExpanded: true,
                                value: _selectedService,
                                dropdownColor: AppColors.bgCard,
                                hint: const Text('Pilih layanan...',
                                    style: TextStyle(
                                        color: AppColors.textMuted)),
                                items: _services.map((s) {
                                  return DropdownMenuItem<ServiceModel>(
                                    value: s,
                                    child: Text(
                                      '${s.name} (${s.priceFormatted}/m³)',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedService = v),
                              ),
                            ),
                    ),
                  ],
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

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? note;

  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bgCard2.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('Readonly',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 10)),
              ),
            ],
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note!,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ],
    );
  }
}