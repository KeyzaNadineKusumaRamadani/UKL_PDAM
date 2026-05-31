import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'min_usage': double.tryParse(_minCtrl.text.trim()) ?? 0,
      'max_usage': double.tryParse(_maxCtrl.text.trim()) ?? 0,
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
    };

    final result = await serviceController.addService(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Layanan berhasil ditambahkan!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Gagal menambah layanan'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _priceCtrl.dispose();
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
        title: const Text('Tambah Layanan',
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
                CustomTextField(
                  label: 'Nama Layanan',
                  hint: 'Contoh: Layanan Tetap',
                  controller: _nameCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Min Pemakaian (m³)',
                  hint: 'Contoh: 40',
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty ? 'Min pemakaian wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Max Pemakaian (m³)',
                  hint: 'Contoh: 100',
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty ? 'Max pemakaian wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Tarif (Rp/m³)',
                  hint: 'Contoh: 10000',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty ? 'Tarif wajib diisi' : null,
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
                      flex: 2,
                      child: CustomButton(
                        text: 'Simpan',
                        isLoading: _isLoading,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}