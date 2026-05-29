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
  bool _isLoading = false;
  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer.name);
    _phoneCtrl = TextEditingController(text: widget.customer.phone);
    _addressCtrl = TextEditingController(text: widget.customer.address);
    _loadServices();
  }

  Future<void> _loadServices() async {
    await serviceController.fetchServices();
    setState(() {
      _services = serviceController.services;
      if (widget.customer.serviceId != null) {
        try {
          _selectedService = _services
              .firstWhere((s) => s.id == widget.customer.serviceId);
        } catch (_) {}
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      if (_selectedService != null) 'service_id': _selectedService!.id,
    };

    final result = await customerController.editCustomer(
        widget.customer.id, data);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['data'] != null || result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer berhasil diperbarui!'),
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
              children: [
                // Username (readonly)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard2.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        widget.customer.username,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'No. Telepon',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'No. Telepon wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Alamat',
                  controller: _addressCtrl,
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 14),

                // Dropdown Layanan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Layanan',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}