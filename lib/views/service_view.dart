import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/app_deader.dart';

import 'package:flutter/material.dart';
import '../widgets/service_tile.dart';

import 'add_service_view.dart';
import 'edit_service_view.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;
  List<ServiceModel> _displayList = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() {
      _isLoading = true;
      _displayList = [];
    });

    await serviceController.fetchServices(search: search);

    if (!mounted) return;

    setState(() {
      _displayList = List.from(serviceController.services.reversed);
      _isLoading = false;
    });
  }

  void _showDeleteDialog(ServiceModel s) {
    showDialog(
      context: context,
      builder: (_) =>
          _DeleteServiceDialog(service: s, onDeleted: () => _load()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: ''),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              color: AppColors.bgCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Layanan',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Kelola data layanan air',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        child: const Text(
                          'Tambah',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddServiceView(),
                            ),
                          );
                          _load();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _load(search: v),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari layanan...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _displayList.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 60,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada layanan',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _displayList.length,
                        itemBuilder: (_, i) {
                          if (i >= _displayList.length) return const SizedBox();
                          final s = _displayList[i];
                          return ServiceTile(
                            service: s,
                            onEdit: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditServiceView(service: s),
                                ),
                              );
                              _load();
                            },
                            onDelete: () => _showDeleteDialog(s),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteServiceDialog extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onDeleted;
  const _DeleteServiceDialog({required this.service, required this.onDeleted});

  @override
  State<_DeleteServiceDialog> createState() => _DeleteServiceDialogState();
}

class _DeleteServiceDialogState extends State<_DeleteServiceDialog> {
  bool _isDeleting = false;
  String _status = '';

  Future<void> _hapus() async {
    setState(() {
      _isDeleting = true;
      _status = 'Memindahkan customer...';
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _status = 'Menghapus tagihan terkait...');
    final result = await serviceController.removeServiceSafe(widget.service.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    final berhasil = result['success'] == true;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? '✅ Layanan "${widget.service.name}" berhasil dihapus'
              : '❌ ${result['message'] ?? 'Gagal hapus layanan'}',
        ),
        backgroundColor: berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (berhasil) widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hapus  Layanan?',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ],
      ),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Hapus layanan '),
                      TextSpan(
                        text: '"${widget.service.name}"',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Customer yang memakai layanan ini akan dipindah ke layanan lain. Tagihan terkait akan dihapus otomatis.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12),
                  ),
                ),
              ],
            ),
      actions: _isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _hapus,
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
    );
  }
}
