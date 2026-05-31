class AdminModel {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String role;

  AdminModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    // API /admins/me bisa return:
    // Format 1: { id, username, name, phone, role }
    // Format 2: { data: { id, username, ... } } -- sudah di-unwrap di controller
    // Format 3: { id, user: { username } }

    final user = json['user'] as Map<String, dynamic>?;

    final rawId = json['id'] ?? json['admin_id'] ?? 0;
    final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    // Username: coba dari root, atau nested 'user'
    final username = (json['username'] ?? user?['username'] ?? json['user_name'] ?? '').toString();

    // Name: coba dari root, atau nested 'user'
    final name = (json['name'] ?? user?['name'] ?? json['full_name'] ?? json['admin_name'] ?? '').toString();

    // Phone
    final phone = (json['phone'] ?? json['phone_number'] ?? json['no_phone'] ?? json['telp'] ?? '').toString();

    // Role
    final role = (json['role'] ?? json['roles'] ?? 'ADMIN').toString();

    return AdminModel(
      id: id,
      username: username,
      name: name,
      phone: phone,
      role: role.toUpperCase(),
    );
  }

  String get initials {
    final source = name.isNotEmpty ? name : username;
    if (source.isEmpty) return 'AD';
    final parts = source.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }
}