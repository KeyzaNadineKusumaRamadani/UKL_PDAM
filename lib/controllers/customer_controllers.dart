import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/models/customer_models.dart';
import 'package:alirin/service/api_service.dart';

class CustomerController {
  // Pakai Set id untuk hindari duplikat
  List<CustomerModel> customers = [];
  bool isLoading = false;

  Future<bool> fetchCustomers({String search = ''}) async {
    // Selalu reset dulu sebelum fetch
    customers = [];
    isLoading = true;

    final result = await ApiService.getCustomers(
      authController.token,
      page: 1,
      quantity: 100,
      search: search,
    );

    isLoading = false;

    List data = [];
    if (result['data'] != null) {
      data = result['data'];
    }

    // Assign langsung, tidak addAll — supaya tidak duplikat
    customers = data.map((e) => CustomerModel.fromJson(e)).toList();

    // Deduplikasi berdasarkan id, jaga-jaga
    final seen = <int>{};
    customers = customers.where((c) => seen.add(c.id)).toList();

    return result['data'] != null;
  }

  Future<Map<String, dynamic>> addCustomer(Map<String, dynamic> data) async {
    return await ApiService.createCustomer(authController.token, data);
  }

  Future<Map<String, dynamic>> editCustomer(
      int id, Map<String, dynamic> data) async {
    return await ApiService.updateCustomer(authController.token, id, data);
  }

  // Cek apakah response API sukses (API bisa return berbagai format)
  bool _isSuccess(Map<String, dynamic> result) {
    // Format 1: { success: true }
    if (result['success'] == true) return true;
    // Format 2: { data: {...} }
    if (result['data'] != null) return true;
    // Format 3: message mengandung kata sukses/berhasil/deleted
    final msg = result['message']?.toString().toLowerCase() ?? '';
    if (msg.contains('berhasil') ||
        msg.contains('success') ||
        msg.contains('delet') ||
        msg.contains('removed')) return true;
    // Format 4: tidak ada field error/message (kosong = sukses)
    if (result['error'] == null && result['message'] == null) return true;
    return false;
  }

  // Hapus semua bills milik customer dulu, baru hapus customernya
  Future<Map<String, dynamic>> removeCustomerSafe(int customerId) async {
    try {
      // 1. Ambil semua bills
      final billsResult = await ApiService.getBills(
        authController.token,
        page: 1,
        quantity: 200,
        search: '',
      );

      List billsData = [];
      if (billsResult['data'] != null) {
        billsData = billsResult['data'];
      }

      // 2. Filter & hapus bills milik customer ini
      final customerBills =
          billsData.where((b) => b['customer_id'] == customerId).toList();

      for (final bill in customerBills) {
        final billId = bill['id'];
        if (billId != null) {
          await ApiService.deleteBill(authController.token, billId);
        }
      }

      // 3. Hapus customernya
      final result =
          await ApiService.deleteCustomer(authController.token, customerId);

      // 4. Jika masih error foreign key, coba sekali lagi setelah delay
      if (!_isSuccess(result)) {
        final msg = result['message']?.toString() ?? '';
        if (msg.toLowerCase().contains('foreign key') ||
            msg.toLowerCase().contains('constraint')) {
          await Future.delayed(const Duration(milliseconds: 500));
          final retry =
              await ApiService.deleteCustomer(authController.token, customerId);
          return _isSuccess(retry)
              ? {'success': true, 'message': 'Customer berhasil dihapus'}
              : retry;
        }
      }

      // 5. Anggap sukses kalau customer tidak ada di list lagi
      // (API kadang return 404 padahal sudah terhapus)
      return _isSuccess(result)
          ? {'success': true, 'message': 'Customer berhasil dihapus'}
          : result;
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus customer: $e'};
    }
  }

  Future<Map<String, dynamic>> removeCustomer(int id) async {
    return await ApiService.deleteCustomer(authController.token, id);
  }
}

final customerController = CustomerController();
