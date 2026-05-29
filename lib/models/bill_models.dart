class BillModel {
  final int id;
  final int customerId;
  final String customerName;
  final String customerNumber;
  final int month;
  final int year;
  final String measurementNumber;
  final double usageValue;
  final double total;
  final String status;
  final String? serviceName;
  final double? price;

  BillModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerNumber,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.total,
    required this.status,
    this.serviceName,
    this.price,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? json['name'] ?? '',
      customerNumber: json['customer_number']?.toString() ?? '',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number']?.toString() ?? '',
      usageValue: double.tryParse(json['usage_value']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'belum_bayar',
      serviceName: json['service_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return month.toString();
  }

  String get totalFormatted {
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get statusLabel {
    switch (status) {
      case 'lunas':
        return 'Lunas';
      case 'menunggu':
      case 'menunggu_verif':
        return 'Menunggu';
      default:
        return 'Belum Bayar';
    }
  }
}