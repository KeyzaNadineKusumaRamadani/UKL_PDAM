import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/models/model_service.dart';
import 'package:alirin/service/api_service.dart';

class ServiceController {
  List<ServiceModel> services = [];
  bool isLoading = false;

  Future<bool> fetchServices({String search = ''}) async {
    services = []; // Selalu reset dulu
    isLoading = true;

    final result = await ApiService.getServices(
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
    services = data.map((e) => ServiceModel.fromJson(e)).toList();

    // Deduplikasi
    final seen = <int>{};
    services = services.where((s) => seen.add(s.id)).toList();

    return result['data'] != null;
  }

  Future<Map<String, dynamic>> addService(Map<String, dynamic> data) async {
    return await ApiService.createService(authController.token, data);
  }

  Future<Map<String, dynamic>> editService(
      int id, Map<String, dynamic> data) async {
    return await ApiService.updateService(authController.token, id, data);
  }

  bool _isSuccess(Map<String, dynamic> result) {
    if (result['success'] == true) return true;
    if (result['data'] != null) return true;
    final msg = result['message']?.toString().toLowerCase() ?? '';
    if (msg.contains('berhasil') ||
        msg.contains('success') ||
        msg.contains('delet') ||
        msg.contains('removed')) return true;
    if (result['error'] == null && result['message'] == null) return true;
    return false;
  }

  Future<Map<String, dynamic>> removeServiceSafe(int serviceId) async {
    try {
      // 1. Ambil semua customers
      final custResult = await ApiService.getCustomers(
        authController.token,
        page: 1,
        quantity: 200,
        search: '',
      );

      List custData = [];
      if (custResult['data'] != null) {
        custData = custResult['data'];
      }

      // 2. Cari customer yang pakai service ini
      final affectedCustomers =
          custData.where((c) => c['service_id'] == serviceId).toList();

      // 3. Cari service lain sebagai pengganti
      final otherServices =
          services.where((s) => s.id != serviceId).toList();
      final replacementId =
          otherServices.isNotEmpty ? otherServices.first.id : null;

      // 4. Ambil semua bills
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

      // 5. Hapus bills dari customer yang terdampak
      for (final cust in affectedCustomers) {
        final custId = cust['id'];
        if (custId == null) continue;

        final custBills =
            billsData.where((b) => b['customer_id'] == custId).toList();
        for (final bill in custBills) {
          final billId = bill['id'];
          if (billId != null) {
            await ApiService.deleteBill(authController.token, billId);
          }
        }
      }

      // 6. Update service_id customer ke layanan lain
      for (final cust in affectedCustomers) {
        final custId = cust['id'];
        if (custId != null && replacementId != null) {
          await ApiService.updateCustomer(
            authController.token,
            custId,
            {'service_id': replacementId},
          );
        }
      }

      // 7. Hapus service
      final result =
          await ApiService.deleteService(authController.token, serviceId);

      return _isSuccess(result)
          ? {'success': true, 'message': 'Layanan berhasil dihapus'}
          : result;
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus layanan: $e'};
    }
  }

  Future<Map<String, dynamic>> removeService(int id) async {
    return await ApiService.deleteService(authController.token, id);
  }
}

final serviceController = ServiceController();