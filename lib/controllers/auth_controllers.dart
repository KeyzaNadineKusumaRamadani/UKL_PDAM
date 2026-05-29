import 'package:alirin/models/admin_models.dart';
import 'package:alirin/service/api_service.dart';

class AuthController {
  String _token = '';
  AdminModel? _adminData;

  String get token => _token;
  AdminModel? get adminData => _adminData;

  // Dummy login lokal, lalu coba API login
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Username dan password wajib diisi'};
    }
    if (username.length < 4) {
      return {'success': false, 'message': 'Username minimal 4 karakter'};
    }
    if (password.length < 4) {
      return {'success': false, 'message': 'Password minimal 4 karakter'};
    }

    // Coba login via API
    final result = await ApiService.login(username, password);

    if (result['token'] != null) {
      _token = result['token'];
      // Cek role harus ADMIN
      final data = result['data'];
      if (data != null && data['role'] != null && data['role'] != 'ADMIN') {
        return {'success': false, 'message': 'Akun ini bukan admin PDAM'};
      }
      if (data != null) {
        _adminData = AdminModel.fromJson(data);
      }
      return {'success': true, 'message': 'Login berhasil'};
    }

    // Fallback dummy login
    if (username == 'admin' && password == 'admin') {
      _token = 'dummy_token_admin';
      _adminData = AdminModel(
        id: 0,
        username: 'admin',
        name: 'Admin PDAM',
        phone: '081234567890',
        role: 'ADMIN',
      );
      return {'success': true, 'message': 'Login berhasil'};
    }

    return {
      'success': false,
      'message': result['message'] ?? 'Username atau password salah'
    };
  }

  Future<void> loadAdminProfile() async {
    if (_token.isEmpty || _token == 'dummy_token_admin') return;
    final result = await ApiService.getAdminMe(_token);
    if (result['data'] != null) {
      _adminData = AdminModel.fromJson(result['data']);
    }
  }

  void logout() {
    _token = '';
    _adminData = null;
  }
}

// Singleton global controller
final authController = AuthController();