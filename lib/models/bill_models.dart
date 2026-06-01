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
    final nested = json['customer'] as Map<String, dynamic>?;
    final serviceJson = json['service'] as Map<String, dynamic>?;
    final paymentsJson = json['payments'] as Map<String, dynamic>?;

    // Nama customer
    String customerName = '';
    if (json['customer_name'] != null &&
        json['customer_name'].toString().isNotEmpty) {
      customerName = json['customer_name'].toString();
    } else if (nested?['name'] != null) {
      customerName = nested!['name'].toString();
    }

    // Status — hanya dari verified_payment dan payments.verified
    String status = 'belum_bayar';
    final bool verifiedPayment = json['verified_payment'] == true;
    final bool hasPayment = paymentsJson != null;
    final bool paymentVerified = paymentsJson?['verified'] == true;

    if (verifiedPayment || paymentVerified) {
      status = 'lunas';
    } else if (hasPayment && !paymentVerified) {
      status = 'menunggu';
    } else {
      status = 'belum_bayar';
    }

    // Total dari amount
    double total = 0;
    if (json['amount'] != null) {
      total = double.tryParse(json['amount'].toString()) ?? 0;
    } else if (json['total'] != null) {
      total = double.tryParse(json['total'].toString()) ?? 0;
    }

    // Price dari nested service
    double? price;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    } else if (serviceJson?['price'] != null) {
      price = double.tryParse(serviceJson!['price'].toString());
    }

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
      total: total,
      status: status,
      serviceName: serviceJson?['name']?.toString() ??
          json['service_name']?.toString() ?? '',
      price: price,
    );
  }

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
        return 'Menunggu Verifikasi';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Belum Bayar';
    }
  }

  String get displayName {
    if (customerName.isNotEmpty) return customerName;
    return 'Customer #$customerId';
  }

  double get totalBill => effectiveTotal;
  bool get isPaid => status == 'lunas';
  bool get isUnpaid => status == 'belum_bayar';
  bool get isRejected => status == 'ditolak';
  bool get isPending => status == 'menunggu' || status == 'menunggu_verif';
  String get dueDate => '10 $monthName $year';
  bool get isOverdue => false;
}