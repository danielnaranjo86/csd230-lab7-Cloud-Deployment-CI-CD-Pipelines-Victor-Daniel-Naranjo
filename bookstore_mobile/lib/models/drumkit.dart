class DrumKit {
  final int id;
  final String brand;
  final dynamic pieces;
  final dynamic model;
  final double price;

  DrumKit({
    required this.id,
    required this.brand,
    required this.pieces,
    required this.model,
    required this.price,
  });

  factory DrumKit.fromJson(Map<String, dynamic> json) {
    return DrumKit(
      id: json['id'],
      brand: json['brand'] ?? '',
      pieces: json['pieces'],
      model: json['model'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}