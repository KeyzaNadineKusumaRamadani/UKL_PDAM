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
    // customer_name bisa ada di root, atau nested di 'customer'
    final nested = json['customer'] as Map<String, dynamic>?;
    String customerName = '';
    if (json['customer_name'] != null &&
        json['customer_name'].toString().isNotEmpty) {
      customerName = json['customer_name'].toString();
    } else if (nested?['name'] != null) {
      customerName = nested!['name'].toString();
    } else if (json['name'] != null) {
      customerName = json['name'].toString();
    }
    // Jika masih kosong, biarkan kosong — controller akan inject dari customerController

    return BillModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? nested?['id'] ?? 0,
      customerName: customerName,
      customerNumber: json['customer_number']?.toString() ??
          nested?['customer_number']?.toString() ?? '',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number']?.toString() ?? '',
      usageValue:
          double.tryParse(json['usage_value']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'belum_bayar',
      serviceName: json['service_name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  // FIX: Jika total dari API = 0 tapi price & usageValue ada,
  // hitung sendiri: usageValue × price
  double get effectiveTotal {
    if (total > 0) return total;
    final p = price ?? 0;
    if (p > 0 && usageValue > 0) return usageValue * p;
    return 0;
  }

  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return month.toString();
  }

  // FIX: pakai effectiveTotal bukan total langsung
  String get totalFormatted {
    final t = effectiveTotal;
    if (t == 0) return 'Rp 0';
    return 'Rp ${t.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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

  // Nama yang ditampilkan — fallback ke ID kalau masih kosong
  String get displayName {
    if (customerName.isNotEmpty) return customerName;
    return 'Customer #$customerId';
  }
}