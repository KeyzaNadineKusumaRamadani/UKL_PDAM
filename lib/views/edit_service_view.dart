import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EditServiceView extends StatefulWidget {
  final ServiceModel service;

  const EditServiceView({super.key, required this.service});

  @override
  State<EditServiceView> createState() => _EditServiceViewState();
}

class _EditServiceViewState extends State<EditServiceView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _priceCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.service.name);
    _minCtrl = TextEditingController(
        text: widget.service.minUsage.toStringAsFixed(0));
    _maxCtrl = TextEditingController(
        text: widget.service.maxUsage.toStringAsFixed(0));
    _priceCtrl = TextEditingController(
        text: widget.service.price.toStringAsFixed(0));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'min_usage': double.tryParse(_minCtrl.text.trim()) ?? 0,
      'max_usage': double.tryParse(_maxCtrl.text.trim()) ?? 0,
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
    };

    final result =
        await serviceController.editService(widget.service.id, data);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil diperbarui!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal update layanan'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Layanan',
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
              children: [
                CustomTextField(
                  label: 'Nama Layanan',
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Min Pemakaian (m³)',
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty
                      ? 'Min pemakaian wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Max Pemakaian (m³)',
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty
                      ? 'Max pemakaian wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Tarif (Rp/m³)',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tarif wajib diisi' : null,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Simpan Perubahan',
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}