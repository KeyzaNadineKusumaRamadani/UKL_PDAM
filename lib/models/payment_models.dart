class PaymentModel {
  final int id;
  final int billId;
  final String customerName;
  final double total;
  final String status;
  final String? proofImage;
  final String? createdAt;
  final int month;
  final int year;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.customerName,
    required this.total,
    required this.status,
    this.proofImage,
    this.createdAt,
    required this.month,
    required this.year,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      customerName: json['customer_name'] ?? json['name'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      proofImage: json['proof_image'] ?? json['file'],
      createdAt: json['created_at'],
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
    );
  }

  String get totalFormatted {
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get monthName {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return month.toString();
  }
}