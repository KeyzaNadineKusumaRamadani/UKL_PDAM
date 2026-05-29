import 'package:alirin/controllers/service_controllers.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/app_collors.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _isLoading = true);
    await serviceController.fetchServices(search: search);
    setState(() => _isLoading = false);
  }

  void _showDeleteDialog(ServiceModel s) {
    showDialog(
      context: context,
      builder: (_) => _DeleteServiceDialog(
        service: s,
        onDeleted: () => _load(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kelola Layanan',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddServiceView()),
                      );
                      _load();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => _load(search: v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari layanan...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.bgCard2,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : serviceController.services.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.water_drop_outlined,
                                  size: 60, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text('Belum ada layanan',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 15)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _load(),
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            itemCount: serviceController.services.length,
                            itemBuilder: (_, i) {
                              final s = serviceController.services[i];
                              return ServiceTile(
                                service: s,
                                onEdit: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditServiceView(service: s),
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

// ===================== DIALOG HAPUS SERVICE =====================
class _DeleteServiceDialog extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onDeleted;

  const _DeleteServiceDialog({
    required this.service,
    required this.onDeleted,
  });

  @override
  State<_DeleteServiceDialog> createState() => _DeleteServiceDialogState();
}

class _DeleteServiceDialogState extends State<_DeleteServiceDialog> {
  bool _isDeleting = false;
  String _statusText = '';

  Future<void> _hapus() async {
    setState(() {
      _isDeleting = true;
      _statusText = 'Memindahkan customer ke layanan lain...';
    });

    // Delay kecil agar user bisa lihat status
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _statusText = 'Menghapus tagihan terkait...');
    }

    final result =
        await serviceController.removeServiceSafe(widget.service.id);

    if (!mounted) return;

    setState(() => _isDeleting = false);

    // Controller sudah normalize response
    final berhasil = result['success'] == true;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? '✅ Layanan "${widget.service.name}" berhasil dihapus'
              : '❌ ${result['message'] ?? 'Gagal menghapus layanan'}',
        ),
        backgroundColor:
            berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );

    if (berhasil) widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    final hasOtherServices = serviceController.services
        .where((s) => s.id != widget.service.id)
        .isNotEmpty;

    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline,
                color: AppColors.danger, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hapus Layanan?',
              style:
                  TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ],
      ),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const CircularProgressIndicator(
                    color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
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
                        color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Hapus layanan '),
                      TextSpan(
                        text: '"${widget.service.name}"',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Warning box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: AppColors.warning, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Perhatian',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasOtherServices
                            ? '• Customer yang memakai layanan ini akan dipindah ke layanan lain\n• Tagihan terkait akan dihapus otomatis'
                            : '• Tidak ada layanan pengganti tersedia\n• Tagihan terkait akan dihapus otomatis',
                        style: const TextStyle(
                            color: AppColors.warning, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: _isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _hapus,
                child: const Text('Hapus',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
    );
  }
}
