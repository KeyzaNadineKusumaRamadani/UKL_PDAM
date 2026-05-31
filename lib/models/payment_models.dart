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
    // API bisa return data dalam berbagai format nested
    // Coba ambil dari root atau dari nested 'bill' / 'customer'
    final bill = json['bill'] as Map<String, dynamic>?;
    final customer = bill?['customer'] as Map<String, dynamic>?;

    // Nama customer: coba dari berbagai field
    String name = '';
    if (json['customer_name'] != null && json['customer_name'].toString().isNotEmpty) {
      name = json['customer_name'].toString();
    } else if (customer?['name'] != null) {
      name = customer!['name'].toString();
    } else if (json['name'] != null) {
      name = json['name'].toString();
    } else if (bill?['customer_name'] != null) {
      name = bill!['customer_name'].toString();
    }

    // Total: coba dari root atau nested bill
    double total = 0;
    if (json['total'] != null) {
      total = double.tryParse(json['total'].toString()) ?? 0;
    } else if (bill?['total'] != null) {
      total = double.tryParse(bill!['total'].toString()) ?? 0;
    }

    // Month & Year dari nested bill atau root
    int month = 0;
    int year = 0;
    if (json['month'] != null) {
      month = int.tryParse(json['month'].toString()) ?? 0;
    } else if (bill?['month'] != null) {
      month = int.tryParse(bill!['month'].toString()) ?? 0;
    }
    if (json['year'] != null) {
      year = int.tryParse(json['year'].toString()) ?? 0;
    } else if (bill?['year'] != null) {
      year = int.tryParse(bill!['year'].toString()) ?? 0;
    }

    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? bill?['id'] ?? 0,
      customerName: name,
      total: total,
      status: json['status']?.toString() ?? 'pending',
      proofImage: json['proof_image'] ?? json['file'] ?? json['image'],
      createdAt: json['created_at'],
      month: month,
      year: year,
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

  bool get isPending => status == 'pending' || status == 'menunggu';
  bool get isVerified => status == 'lunas' || status == 'verified' || status == 'verif';
  bool get isRejected => status == 'ditolak' || status == 'rejected';
}