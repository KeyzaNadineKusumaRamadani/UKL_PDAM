import 'package:alirin/models/bill_models.dart';

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
  final BillModel? bill;

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
    this.bill,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final billJson = json['bill'] as Map<String, dynamic>?;
    final customer = billJson?['customer'] as Map<String, dynamic>?;

    // Nama customer dari bill.customer.name
    String name = '';
    if (customer?['name'] != null) {
      name = customer!['name'].toString();
    } else if (json['customer_name'] != null) {
      name = json['customer_name'].toString();
    }

    // Total dari total_amount
    double total = 0;
    if (json['total_amount'] != null) {
      total = double.tryParse(json['total_amount'].toString()) ?? 0;
    } else if (json['total'] != null) {
      total = double.tryParse(json['total'].toString()) ?? 0;
    } else if (billJson?['amount'] != null) {
      total = double.tryParse(billJson!['amount'].toString()) ?? 0;
    }

    // Month & Year dari bill
    int month = billJson?['month'] ?? json['month'] ?? 0;
    int year = billJson?['year'] ?? json['year'] ?? 0;

    // Status dari verified boolean
    String status = 'pending';
    if (json['verified'] == true) {
      status = 'lunas';
    }

    // Proof image dari payment_proof
    String? proofImage = json['payment_proof'] ??
        json['proof_image'] ??
        json['file'];

    // Created at
    String? createdAt = json['createdAt'] ??
        json['created_at'] ??
        json['payment_date'];

    // Parse nested bill
    BillModel? billModel;
    if (billJson != null) {
      try {
        billModel = BillModel.fromJson(billJson);
      } catch (_) {}
    }

    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? billJson?['id'] ?? 0,
      customerName: name,
      total: total,
      status: status,
      proofImage: proofImage,
      createdAt: createdAt,
      month: month,
      year: year,
      bill: billModel,
    );
  }

  String get totalFormatted {
    if (total == 0) return 'Rp 0';
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get monthName {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '-';
  }

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'lunas';
  bool get isRejected => status == 'ditolak';
  bool get isPaid => isVerified;
}