import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/models/bill_models.dart';
import 'package:alirin/models/payment_models.dart';
import 'package:alirin/service/api_service.dart';


class BillController {
  List<BillModel> bills = [];
  List<PaymentModel> payments = [];
  bool isLoading = false;

  Future<bool> fetchBills({String search = ''}) async {
    bills = []; // Selalu reset
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

    return result['data'] != null;
  }

  Future<Map<String, dynamic>> addBill(Map<String, dynamic> data) async {
    return await ApiService.createBill(authController.token, data);
  }

  Future<Map<String, dynamic>> removeBill(int id) async {
    return await ApiService.deleteBill(authController.token, id);
  }

  Future<bool> fetchPayments() async {
    payments = []; // Selalu reset
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
    return await ApiService.verifyPayment(authController.token, id);
  }

  Future<Map<String, dynamic>> rejectPayment(int id) async {
    return await ApiService.rejectPayment(authController.token, id);
  }

  int get totalBills => bills.length;
  int get unpaidBills =>
      bills.where((b) => b.status == 'belum_bayar').length;
  int get pendingPayments => payments
      .where((p) => p.status == 'pending' || p.status == 'menunggu')
      .length;
}

final billController = BillController();
