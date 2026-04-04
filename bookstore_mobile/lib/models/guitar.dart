class Guitar {
  final int id;
  final String brand;
  final String model;
  final double price;

  Guitar({
    required this.id,
    required this.brand,
    required this.model,
    required this.price,
  });

  factory Guitar.fromJson(Map<String, dynamic> json) {
    return Guitar(
      id: json['id'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}