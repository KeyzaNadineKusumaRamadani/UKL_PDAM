class CustomerModel {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String address;
  final String? customerNumber;
  final int? serviceId;
  final String? serviceName;

  CustomerModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
    this.customerNumber,
    this.serviceId,
    this.serviceName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      customerNumber: json['customer_number']?.toString() ?? '',
      serviceId: json['service_id'],
      serviceName: json['service_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'phone': phone,
      'address': address,
      'customer_number': customerNumber,
      'service_id': serviceId,
    };
  }
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'C';
  String get memberSince => '2024';

}