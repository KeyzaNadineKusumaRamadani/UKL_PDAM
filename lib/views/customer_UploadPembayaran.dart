import 'package:alirin/models/customer_models.dart';
import 'package:alirin/service/api_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/customer_StatusPembayaran.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/bill_models.dart';  

class CustomerUploadBuktiPage extends StatefulWidget {
  final BillModel bill;
  final CustomerModel? customer;

  const CustomerUploadBuktiPage({
    super.key,
    required this.bill,
    this.customer,
  });

  @override
  State<CustomerUploadBuktiPage> createState() =>
      _CustomerUploadBuktiPageState();
}

class _CustomerUploadBuktiPageState extends State<CustomerUploadBuktiPage> {
  File? _image;
  bool _isLoading = false;
  String _imageName = '';
  String _imageSize = '';

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final file = File(picked.path);
      final size = await file.length();
      setState(() {
        _image = file;
        _imageName = picked.name;
        _imageSize = '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
      });
    }
  }

  Future<void> _upload() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bukti pembayaran terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.createPayment(
        widget.bill.id, _image!.path);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result['success'] != false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti berhasil diupload'),
          backgroundColor: AppColors.success,
        ),
      );
      final paymentId = result['id'] ?? result['data']?['id'];
      if (paymentId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerStatusPembayaranPage(
              paymentId: paymentId,
            ),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } else {
      final msg = result?['message']?.toString() ??
          'Gagal upload bukti pembayaran';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $msg'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Bukti Pembayaran',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Silahkan unggah bukti pembayaranmu untuk kami verifikasi',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),

              // Detail Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.person_outline, 'Customer',
                        widget.bill.displayName),
                    const Divider(height: 24),
                    _detailRow(Icons.calendar_month, 'Periode',
                        '${widget.bill.monthName} ${widget.bill.year}'),
                    const Divider(height: 24),
                    _detailRow(Icons.water_drop_outlined, 'Pemakaian',
                        '${widget.bill.usageValue} m³'),
                    const Divider(height: 24),
                    _detailRow(Icons.speed, 'Meter',
                        widget.bill.measurementNumber),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total tagihan',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.bill.totalFormatted,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                                fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upload Box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 1.5),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          color: Colors.blue, size: 40),
                      SizedBox(height: 12),
                      Text('Pilih foto bukti pembayaran',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Format JPG/PNG',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected File
              if (_image != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_imageName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(_imageSize,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: AppColors.success),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim bukti bayar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(color: Colors.grey))),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}