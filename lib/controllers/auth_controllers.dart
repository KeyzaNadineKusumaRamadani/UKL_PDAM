import 'dart:developer';
import 'package:alirin/models/admin_models.dart';
import 'package:alirin/service/api_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  String _token = '';
  String _role = '';
  AdminModel? _adminData;

  String get token => _token;
  String get role => _role;
  AdminModel? get adminData => _adminData;

  Future<Map<String, dynamic>> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Username dan password wajib diisi', 'role': ''};
    }
    if (username.length < 4) {
      return {'success': false, 'message': 'Username minimal 4 karakter', 'role': ''};
    }
    if (password.length < 4) {
      return {'success': false, 'message': 'Password minimal 4 karakter', 'role': ''};
    }

    final result = await ApiService.login(username, password);
    log('LOGIN RESPONSE: $result');

    if (result['token'] != null) {
      _token = result['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token);

      final data = result['data'];
      final rawRole = (result['role'] ?? data?['role'] ?? '').toString().toUpperCase();
      log('RAW ROLE: $rawRole');

      if (rawRole == 'ADMIN') {
        _role = 'admin';

        if (data != null) {
          _adminData = AdminModel.fromJson(data);
        }

        await loadAdminProfile();

        if (_adminData == null) {
          _adminData = AdminModel(
            id: 0,
            username: username,
            name: username,
            phone: '',
            role: 'ADMIN',
          );
        }
        if (_adminData!.name.isEmpty) {
          _adminData = AdminModel(
            id: _adminData!.id,
            username: _adminData!.username,
            name: _adminData!.username.isNotEmpty ? _adminData!.username : username,
            phone: _adminData!.phone,
            role: _adminData!.role,
          );
        }

        return {'success': true, 'message': 'Login berhasil', 'role': 'admin'};
      } else {
        _role = 'customer';
        return {'success': true, 'message': 'Login berhasil', 'role': 'customer'};
      }
    }

    return {
      'success': false,
      'message': result['message'] ?? 'Username atau password salah',
      'role': ''
    };
  }

  Future<void> loadAdminProfile() async {
    if (_token.isEmpty || _token == 'dummy_token_admin') return;
    try {
      final result = await ApiService.getAdminMe(_token);
      log('ADMIN ME RESPONSE: $result');

      Map<String, dynamic>? adminJson;

      if (result['data'] != null) {
        adminJson = result['data'] as Map<String, dynamic>;
      } else if (result['id'] != null) {
        adminJson = result;
      }

      if (adminJson != null) {
        _adminData = AdminModel.fromJson(adminJson);
        log('ADMIN PARSED: id=${_adminData?.id} username=${_adminData?.username} name=${_adminData?.name}');

        if (_adminData != null && (_adminData!.name.isEmpty)) {
          _adminData = AdminModel(
            id: _adminData!.id,
            username: _adminData!.username,
            name: _adminData!.username.isNotEmpty ? _adminData!.username : 'Admin',
            phone: _adminData!.phone,
            role: _adminData!.role,
          );
        }
      }
    } catch (e) {
      log('loadAdminProfile ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      int adminId, Map<String, dynamic> data) async {
    if (adminId == 0) {
      await loadAdminProfile();
      adminId = _adminData?.id ?? 0;
    }

    if (adminId == 0) {
      return {
        'success': false,
        'message': 'ID Admin tidak ditemukan. Pastikan login menggunakan akun real dari API.'
      };
    }

    return await ApiService.updateAdmin(_token, adminId, data);
  }

  void updateLocalAdmin(AdminModel newData) {
    _adminData = newData;
  }

  void logout() {
    _token = '';
    _role = '';
    _adminData = null;
    SharedPreferences.getInstance().then((p) => p.clear());
  }
}

final authController = AuthController();