import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/app_deader.dart';
import 'package:flutter/material.dart';
import '../widgets/customer_tile.dart';
import 'add_customer_view.dart';
import 'edit_customer_view.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _isLoading = true);
    await customerController.fetchCustomers(search: search);
    if (mounted) setState(() => _isLoading = false);
  }

  void _showDeleteDialog(CustomerModel c) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(customer: c, onDeleted: () => _load()),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: AppColors.bgCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Kelola Customer',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        child: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddCustomerView()));
                          _load();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _load(search: v),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari Customer / NIK',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : customerController.customers.isEmpty
                      ? const _EmptyState(icon: Icons.people_outline, message: 'Belum ada customer')
                      : RefreshIndicator(
                          onRefresh: () => _load(),
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: customerController.customers.length,
                            itemBuilder: (_, i) {
                              final c = customerController.customers[i];
                              return CustomerTile(
                                customer: c,
                                onEdit: () async {
                                  await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => EditCustomerView(customer: c)));
                                  _load();
                                },
                                onDelete: () => _showDeleteDialog(c),
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

class _DeleteDialog extends StatefulWidget {
  final CustomerModel customer;
  final VoidCallback onDeleted;

  const _DeleteDialog({
    required this.customer,
    required this.onDeleted,
  });

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  bool _isDeleting = false;
  String _status = '';

  Future<void> _hapus() async {
    setState(() {
      _isDeleting = true;
      _status = 'Menghapus customer...';
    });

    final result =
        await customerController.removeCustomerSafe(widget.customer.id);

    if (!mounted) return;

    setState(() => _isDeleting = false);

    final berhasil = result['success'] == true;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? '✅ Customer "${widget.customer.name}" berhasil dihapus'
              : '❌ ${result['message'] ?? 'Gagal hapus customer'}',
        ),
        backgroundColor:
            berhasil ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (berhasil) {
      widget.onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
              'Hapus Customer?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
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
                      const TextSpan(
                        text: 'Hapus customer ',
                      ),
                      TextSpan(
                        text: '"${widget.customer.name}"',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: '?',
                      ),
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
                      color:
                          AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Semua data tagihan customer terkait juga dapat terhapus otomatis.',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 60, color: AppColors.textMuted.withOpacity(0.4)),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
    ]));
  }
}