import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/controllers/customer_controllers.dart';
import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/api_service.dart';



class BillController {
  List<BillModel> bills = [];
  List<PaymentModel> payments = [];
  bool isLoading = false;

  Future<bool> fetchBills({String search = ''}) async {
    bills = [];
    isLoading = true;

    final result = await ApiService.getBills(
      authController.token,
      page: 1,
      quantity: 50,
      search: search,
    );

    isLoading = false;

    List data = [];
    if (result['data'] != null) {
      data = result['data'];
    }

    bills = data.map((e) => BillModel.fromJson(e)).toList();

    // Deduplikasi
    final seen = <int>{};
    bills = bills.where((b) => seen.add(b.id)).toList();

    // Inject nama customer dari customerController jika customer_name kosong
    _injectCustomerNames();

    return result['data'] != null;
  }

  // Cari nama customer dari list customer berdasarkan customer_id
  void _injectCustomerNames() {
    if (customerController.customers.isEmpty) return;
    final custMap = <int, String>{};
    for (final c in customerController.customers) {
      custMap[c.id] = c.name;
    }
    bills = bills.map((b) {
      if (b.customerName.isEmpty || b.customerName == 'Customer #${b.customerId}') {
        final name = custMap[b.customerId];
        if (name != null && name.isNotEmpty) {
          return BillModel(
            id: b.id,
            customerId: b.customerId,
            customerName: name,
            customerNumber: b.customerNumber,
            month: b.month,
            year: b.year,
            measurementNumber: b.measurementNumber,
            usageValue: b.usageValue,
            total: b.total,
            status: b.status,
            serviceName: b.serviceName,
            price: b.price,
          );
        }
      }
      return b;
    }).toList();
  }

  Future<Map<String, dynamic>> addBill(Map<String, dynamic> data) async {
    // Guard token kosong sebelum kirim request
    if (authController.token.isEmpty) {
      return {'success': false, 'message': 'Token tidak valid, silakan login ulang'};
    }
    return await ApiService.createBill(authController.token, data);
  }

  // FIX: tambah editBill untuk update tagihan
  Future<Map<String, dynamic>> editBill(int id, Map<String, dynamic> data) async {
    if (authController.token.isEmpty) {
      return {'success': false, 'message': 'Token tidak valid, silakan login ulang'};
    }
    final result = await ApiService.updateBill(authController.token, id, data);
    final berhasil = _isSuccess(result);
    if (berhasil) {
      // Update data lokal supaya tidak perlu fetch ulang
      bills = bills.map((b) {
        if (b.id == id) {
          return BillModel(
            id: b.id,
            customerId: b.customerId,
            customerName: b.customerName,
            customerNumber: b.customerNumber,
            month: data['month'] ?? b.month,
            year: data['year'] ?? b.year,
            measurementNumber: data['measurement_number'] ?? b.measurementNumber,
            usageValue: (data['usage_value'] as num?)?.toDouble() ?? b.usageValue,
            total: b.total,
            status: b.status,
            serviceName: b.serviceName,
            price: b.price,
          );
        }
        return b;
      }).toList();
    }
    return berhasil
        ? {'success': true, 'message': result['message'] ?? 'Tagihan berhasil diupdate'}
        : result;
  }

  Future<Map<String, dynamic>> removeBill(int id) async {
    return await ApiService.deleteBill(authController.token, id);
  }

  Future<bool> fetchPayments() async {
    payments = [];
    isLoading = true;

    final result = await ApiService.getPayments(authController.token);

    isLoading = false;

    List data = [];
    if (result['data'] != null) {
      data = result['data'];
    }

    payments = data.map((e) => PaymentModel.fromJson(e)).toList();

    // Deduplikasi
    final seen = <int>{};
    payments = payments.where((p) => seen.add(p.id)).toList();

    return result['data'] != null;
  }

  Future<Map<String, dynamic>> verifyPayment(int id) async {
    final result = await ApiService.verifyPayment(authController.token, id);

    final berhasil = _isSuccess(result);
    if (berhasil) {
      payments = payments.map((p) {
        if (p.id == id) {
          return PaymentModel(
            id: p.id,
            billId: p.billId,
            customerName: p.customerName,
            total: p.total,
            status: 'lunas',
            proofImage: p.proofImage,
            createdAt: p.createdAt,
            month: p.month,
            year: p.year,
          );
        }
        return p;
      }).toList();
    }

    return berhasil
        ? {'success': true, 'message': result['message'] ?? 'Pembayaran diverifikasi'}
        : result;
  }

  Future<Map<String, dynamic>> rejectPayment(int id) async {
    final result = await ApiService.rejectPayment(authController.token, id);

    final berhasil = _isSuccess(result);
    if (berhasil) {
      payments = payments.map((p) {
        if (p.id == id) {
          return PaymentModel(
            id: p.id,
            billId: p.billId,
            customerName: p.customerName,
            total: p.total,
            status: 'ditolak',
            proofImage: p.proofImage,
            createdAt: p.createdAt,
            month: p.month,
            year: p.year,
          );
        }
        return p;
      }).toList();
    }

    return berhasil
        ? {'success': true, 'message': result['message'] ?? 'Pembayaran ditolak'}
        : result;
  }

  bool _isSuccess(Map<String, dynamic> result) {
    if (result['success'] == true) return true;
    if (result['data'] != null) return true;
    final msg = result['message']?.toString().toLowerCase() ?? '';
    if (msg.contains('success') || msg.contains('verif') ||
        msg.contains('berhasil') || msg.contains('payment') ||
        msg.contains('updated') || msg.contains('deleted')) return true;
    // Tidak ada field error = sukses
    if (result['error'] == null && result['success'] == null &&
        result['message'] == null) return true;
    return false;
  }

  int get totalBills => bills.length;
  int get unpaidBills => bills.where((b) => b.status == 'belum_bayar').length;
  int get pendingPayments => payments.where((p) => p.isPending).length;
}

final billController = BillController();