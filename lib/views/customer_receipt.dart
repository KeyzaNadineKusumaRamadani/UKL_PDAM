import 'dart:io';
import 'dart:typed_data';

import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


class CustomerReceiptPage extends StatefulWidget {
  final PaymentModel payment;
  final BillModel? bill;
  final CustomerModel? customer;

  const CustomerReceiptPage({
    super.key,
    required this.payment,
    this.bill,
    this.customer,
  });

  @override
  State<CustomerReceiptPage> createState() => _CustomerReceiptPageState();
}

class _CustomerReceiptPageState extends State<CustomerReceiptPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isSaving = false;
  bool _isSharing = false;

  // ─────────────────────── helpers ───────────────────────

  bool get _isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  String get _noNota {
    final id = widget.payment.id.toString().padLeft(6, '0');
    return 'PDAM-$id';
  }

  String get _customerName =>
      widget.customer?.name ??
      widget.bill?.customerName ??
      widget.payment.customerName;

  String get _customerNumber =>
      widget.customer?.customerNumber ??
      widget.bill?.customerNumber ??
      '-';

  String get _serviceName =>
      widget.customer?.serviceName ??
      widget.bill?.serviceName ??
      '-';

  String get _periode =>
      widget.bill != null
          ? '${widget.bill!.monthName} ${widget.bill!.year}'
          : '${widget.payment.monthName} ${widget.payment.year}';

  // ✅ Fix format Rp — ambil dari bill dulu, fallback ke payment
  String get _totalStr {
    final billTotal = widget.bill?.effectiveTotal ?? 0;
    final paymentTotal = widget.payment.total;
    final total = billTotal > 0 ? billTotal : paymentTotal;
    return _formatRupiah(total);
  }

  // ✅ Format rupiah yang benar — tidak ada desimal, pakai titik ribuan
  String _formatRupiah(double val) {
    if (val == 0) return 'Rp 0';
    return 'Rp ${val.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ─────────────────────── actions ───────────────────────

  Future<Uint8List?> _capture() async {
    return screenshotController.capture(pixelRatio: 2.5);
  }

  Future<void> _saveReceipt() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final image = await _capture();
      if (image == null) throw Exception('Gagal mengambil gambar nota');

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'nota_pdam_${widget.payment.id}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(image);

      if (!mounted) return;
      _snack('Nota disimpan: ${file.path}', Colors.green);
    } catch (e) {
      if (mounted) _snack('Gagal menyimpan: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareReceipt() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final image = await _capture();
      if (image == null) throw Exception('Gagal mengambil gambar nota');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/nota_pdam_${widget.payment.id}.png');
      await file.writeAsBytes(image);

      if (_isDesktop) {
        // ✅ Di Windows: simpan ke Documents lalu buka foldernya
        final docsDir = await getApplicationDocumentsDirectory();
        final savedFile =
            File('${docsDir.path}/nota_pdam_${widget.payment.id}.png');
        await savedFile.writeAsBytes(image);

        if (!mounted) return;
        _snack(
          'Nota disimpan di Documents. Bagikan file secara manual ke WA.',
          Colors.blue,
        );

        // Buka folder di Windows Explorer
        await Process.run('explorer.exe', [docsDir.path]);
      } else {
        // ✅ Di Android/iOS: share normal dengan foto
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Nota Pembayaran PDAM Alirin — $_noNota',
          text: 'Nota pembayaran PDAM Alirin atas nama $_customerName '
              'periode $_periode sejumlah $_totalStr',
        );
      }
    } catch (e) {
      if (mounted) _snack('Gagal membagikan: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─────────────────────── build ───────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'Nota Pembayaran',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: Center(
                  child: Screenshot(
                    controller: screenshotController,
                    child: _buildReceipt(),
                  ),
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ─── receipt card ───────────────────────────────────────
  Widget _buildReceipt() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSuccessBadge(),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _sectionTitle('Informasi Transaksi'),
                _row('No. Nota', _noNota),
                _row('Tanggal Bayar', _formatDate(widget.payment.createdAt)),
                _row('Metode', 'Transfer Bank'),
                _row('Status', 'Terverifikasi ✓'),

                _dashedDivider(),

                _sectionTitle('Data Pelanggan'),
                _row('Nama', _customerName),
                _row('No. Pelanggan', _customerNumber),
                if (_serviceName.isNotEmpty && _serviceName != '-')
                  _row('Jenis Layanan', _serviceName),

                _dashedDivider(),

                _sectionTitle('Detail Tagihan'),
                _row('Periode', _periode),
                if (widget.bill != null) ...[
                  _row(
                    'No. Meter',
                    widget.bill!.measurementNumber.isNotEmpty
                        ? widget.bill!.measurementNumber
                        : '-',
                  ),
                  _row(
                    'Pemakaian',
                    '${widget.bill!.usageValue.toStringAsFixed(0)} m³',
                  ),
                ],

                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _totalStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'ALIRIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'PDAM — Perusahaan Daerah Air Minum',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 4),
          const Text(
            'NOTA PEMBAYARAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 44),
          ),
          const SizedBox(height: 10),
          const Text(
            'PEMBAYARAN BERHASIL',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          _dashedDivider(),
          const SizedBox(height: 12),
          const Icon(Icons.water_drop, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            'Terima kasih atas pembayaran Anda.',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan resi ini sebagai bukti pembayaran yang sah.\nHubungi kami jika ada pertanyaan.',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'www.pdam-alirin.id  |  Telp: (0341) 123456',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ─── bottom action bar ───────────────────────────────────
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -4),
            blurRadius: 12,
          )
        ],
      ),
      child: Row(
        children: [
          // ── Download ──
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _saveReceipt,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : const Icon(Icons.download_rounded,
                      color: AppColors.primary),
              label: Text(
                _isSaving ? 'Menyimpan...' : 'Download',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side:
                    const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Share — label beda di desktop vs mobile ──
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareReceipt,
              icon: _isSharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(
                      _isDesktop
                          ? Icons.folder_open_rounded
                          : Icons.share_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                _isSharing
                    ? 'Memproses...'
                    : _isDesktop
                        ? 'Buka Folder'
                        : 'Bagikan',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── small helpers ───────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(builder: (_, c) {
        const w = 5.0, gap = 3.0;
        final n = (c.maxWidth / (w + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            n,
            (_) => Container(
                width: w,
                height: 1,
                color: Colors.grey.withOpacity(0.35)),
          ),
        );
      }),
    );
  }
}