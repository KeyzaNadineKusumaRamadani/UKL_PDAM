import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    if (serviceController.services.isNotEmpty) {
      setState(() => _services = serviceController.services);
      return;
    }
    await serviceController.fetchServices();
    if (mounted) setState(() => _services = serviceController.services);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih layanan terlebih dahulu'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'username': _usernameCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      'customer_number': _nikCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'service_id': _selectedService!.id,
    };

    final result = await customerController.addCustomer(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Customer berhasil ditambahkan!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal menambah customer'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nikCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Customer',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Akun ──
                _SectionLabel(label: 'Akun Login'),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Username',
                  hint: 'Contoh: cust_budi',
                  controller: _usernameCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Username wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                ),

                const SizedBox(height: 20),

                // ── Data Pribadi ──
                _SectionLabel(label: 'Data Pribadi'),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Nama Lengkap',
                  hint: 'Contoh: Budi Santoso',
                  controller: _nameCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'NIK (No. Pelanggan)',
                  hint: 'Contoh: 35070812345678',
                  controller: _nikCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'NIK wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'No. Telepon',
                  hint: 'Contoh: 081234567890',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'No. Telepon wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Alamat',
                  hint: 'Jl. Soekarno Hatta No. 10, Malang',
                  controller: _addressCtrl,
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),

                const SizedBox(height: 20),

                // ── Layanan ──
                _SectionLabel(label: 'Jenis layanan'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ServiceModel>(
                      isExpanded: true,
                      value: _selectedService,
                      dropdownColor: AppColors.bgCard,
                      hint: const Text('Pilih layanan...',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      items: _services.map((s) => DropdownMenuItem<ServiceModel>(
                        value: s,
                        child: Text('${s.name} (${s.priceFormatted}/m³)',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedService = v),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(

                      child: CustomButton(
                        text: 'Simpan',
                        isLoading: _isLoading,
                        onPressed: _save,
                      ),
                    ),
                  ],
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}