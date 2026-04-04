class CartItem {
  final int id;
  final String name;
  final double price;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String itemName = 'Unknown Item';

    if (json['title'] != null && json['title'].toString().trim().isNotEmpty) {
      itemName = json['title'];
    } else if (json['description'] != null &&
        json['description'].toString().trim().isNotEmpty) {
      itemName = json['description'];
    } else if (json['brand'] != null &&
        json['model'] != null &&
        json['brand'].toString().trim().isNotEmpty &&
        json['model'].toString().trim().isNotEmpty) {
      itemName = '${json['brand']} ${json['model']}';
    } else if (json['brand'] != null &&
        json['pieces'] != null &&
        json['brand'].toString().trim().isNotEmpty) {
      itemName = '${json['brand']} (${json['pieces']} pieces)';
    } else if (json['brand'] != null &&
        json['brand'].toString().trim().isNotEmpty) {
      itemName = json['brand'];
    }

    return CartItem(
      id: json['id'],
      name: itemName,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}