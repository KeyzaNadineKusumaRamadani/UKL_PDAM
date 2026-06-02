import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/pdam';
  static const String appKey = 'cddc1e4bbff2a2e6d1c9dc05b0ad0f08189c82b4';

  static Map<String, String> headers(String token) {
    return {
      'Content-Type': 'application/json',
      'app-key': appKey,
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> headersNoAuth() {
    return {
      'Content-Type': 'application/json',
      'app-key': appKey,
    };
  }

  // ===================== AUTH =====================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth'),
        headers: headersNoAuth(),
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ===================== REGISTER ADMIN =====================
  static Future<Map<String, dynamic>> registerAdmin(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admins'),
        headers: headersNoAuth(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return {'success': true, ...body};
      }
      final body = jsonDecode(response.body);
      return {'success': false, 'message': body['message'] ?? 'Registrasi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // ===================== ADMIN ME =====================
  static Future<Map<String, dynamic>> getAdminMe(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admins/me'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat profil: $e'};
    }
  }

  // ===================== UPDATE ADMIN =====================
  static Future<Map<String, dynamic>> updateAdmin(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admins/$id'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update profil: $e'};
    }
  }

  // ===================== CUSTOMERS =====================
  static Future<Map<String, dynamic>> getCustomers(String token,
      {int page = 1, int quantity = 20, String search = ''}) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/customers?page=$page&quantity=$quantity&search=$search');
      final response = await http.get(uri, headers: headers(token));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat customer: $e'};
    }
  }

  static Future<Map<String, dynamic>> createCustomer(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat customer: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCustomer(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/customers/$id'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update customer: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteCustomer(
      String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$id'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus customer: $e'};
    }
  }

  // ===================== SERVICES =====================
  static Future<Map<String, dynamic>> getServices(String token,
      {int page = 1, int quantity = 20, String search = ''}) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/services?page=$page&quantity=$quantity&search=$search');
      final response = await http.get(uri, headers: headers(token));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat layanan: $e'};
    }
  }

  static Future<Map<String, dynamic>> createService(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat layanan: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateService(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/services/$id'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update layanan: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteService(
      String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/services/$id'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus layanan: $e'};
    }
  }

  // ===================== BILLS =====================
  static Future<Map<String, dynamic>> getBills(String token,
      {int page = 1, int quantity = 20, String search = ''}) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/bills?page=$page&quantity=$quantity&search=$search');
      final response = await http.get(uri, headers: headers(token));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat tagihan: $e'};
    }
  }

  static Future<Map<String, dynamic>> createBill(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bills'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal membuat tagihan: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateBill(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bills/$id'),
        headers: headers(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update tagihan: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteBill(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bills/$id'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal hapus tagihan: $e'};
    }
  }

  // ===================== PAYMENTS =====================
  static Future<Map<String, dynamic>> getPayments(String token,
      {int page = 1, int quantity = 50}) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/payments?page=$page&quantity=$quantity&search=');
      final response = await http.get(uri, headers: headers(token));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat pembayaran: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(
      String token, int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/payments/$id'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal verifikasi pembayaran: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectPayment(
      String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payments/$id'),
        headers: headers(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal tolak pembayaran: $e'};
    }
  }

  // ===================== CUSTOMER METHODS =====================
  static Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/customers/me'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil profil'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateMyProfile(
      int id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.patch(
        Uri.parse('$baseUrl/customers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal update profil: $e'};
    }
  }

  static Future<Map<String, dynamic>> getServiceById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/services/$id'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil service'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyBills(
      {int page = 1, int quantity = 100}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/bills/me'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil tagihan'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyPayments(
      {int page = 1, int quantity = 100}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/payments/me'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil pembayaran'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ===================== CREATE PAYMENT (FIX) =====================
  static Future<Map<String, dynamic>?> createPayment(
      int billId, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      print('=== CREATE PAYMENT ===');
      print('billId: $billId');
      print('filePath: $filePath');
      print('token: $token');

      // Tentukan tipe file dari ekstensi
      final ext = filePath.split('.').last.toLowerCase();
      final mediaType = ext == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      final uri = Uri.parse('$baseUrl/payments');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'app-key': appKey,
        'Authorization': 'Bearer $token',
      });
      request.fields['bill_id'] = billId.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: mediaType,
        ),
      );

      print('Sending request...');
      final streamed = await request.send();
      final respBody = await streamed.stream.bytesToString();

      print('Status: ${streamed.statusCode}');
      print('Response: $respBody');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final decoded = jsonDecode(respBody);
        return decoded['data'] ?? decoded;
      }
      final decoded = jsonDecode(respBody);
      return {
        'success': false,
        'message': decoded['message'] ?? 'Upload gagal'
      };
    } catch (e) {
      print('createPayment ERROR: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static String paymentProofUrl(String filename) {
    return '$baseUrl/payment-proof/$filename';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> getMyPaymentDetail(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/payments/me/$id'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {
        'success': false,
        'message': 'Gagal mengambil detail pembayaran'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyBillById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/bills/me/$id'),
        headers: {
          'app-key': appKey,
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {
        'success': false,
        'message': 'Gagal mengambil tagihan detail'
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}