class ServiceModel {
  final int id;
  final String name;
  final double minUsage;
  final double maxUsage;
  final double price;

  ServiceModel({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      minUsage: double.tryParse(json['min_usage']?.toString() ?? '0') ?? 0,
      maxUsage: double.tryParse(json['max_usage']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'min_usage': minUsage,
      'max_usage': maxUsage,
      'price': price,
    };
  }

  String get priceFormatted {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}