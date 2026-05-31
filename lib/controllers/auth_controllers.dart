import 'dart:developer';
import 'package:alirin/models/admin_models.dart';
import 'package:alirin/service/api_service.dart';



class AuthController {
  String _token = '';
  AdminModel? _adminData;

  String get token => _token;
  AdminModel? get adminData => _adminData;

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

    final result = await ApiService.login(username, password);
    log('LOGIN RESPONSE: $result');

    if (result['token'] != null) {
      _token = result['token'];

      final data = result['data'];
      if (data != null && data['role'] != null &&
          data['role'].toString().toUpperCase() != 'ADMIN') {
        _token = '';
        return {'success': false, 'message': 'Akun ini bukan admin PDAM'};
      }

      if (data != null) {
        _adminData = AdminModel.fromJson(data);
      }

      // Fetch profil lengkap
      await loadAdminProfile();

      // Fallback jika profil tidak berhasil diload
      if (_adminData == null) {
        _adminData = AdminModel(
          id: 0,
          username: username,
          name: username,
          phone: '',
          role: 'ADMIN',
        );
      }

      // FIX: Fallback jika name kosong, pakai username agar tidak tampil "Unknown Admin"
      if (_adminData!.name.isEmpty) {
        _adminData = AdminModel(
          id: _adminData!.id,
          username: _adminData!.username,
          name: _adminData!.username.isNotEmpty ? _adminData!.username : username,
          phone: _adminData!.phone,
          role: _adminData!.role,
        );
      }

      return {'success': true, 'message': 'Login berhasil'};
    }

    // Dummy login fallback
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
    try {
      final result = await ApiService.getAdminMe(_token);
      log('ADMIN ME RESPONSE: $result');

      Map<String, dynamic>? adminJson;

      if (result['data'] != null) {
        // Format: { data: { id, username, ... } }
        adminJson = result['data'] as Map<String, dynamic>;
      } else if (result['id'] != null) {
        // Format langsung: { id, username, ... }
        adminJson = result;
      }

      if (adminJson != null) {
        _adminData = AdminModel.fromJson(adminJson);
        log('ADMIN PARSED: id=${_adminData?.id} username=${_adminData?.username} name=${_adminData?.name}');

        // FIX: Jika name kosong setelah parse, fallback ke username agar tidak "Unknown Admin"
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

  // Update profil via API
  Future<Map<String, dynamic>> updateProfile(
      int adminId, Map<String, dynamic> data) async {
    // Coba fetch ulang ID jika masih 0
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
    _adminData = null;
  }
}

final authController = AuthController();