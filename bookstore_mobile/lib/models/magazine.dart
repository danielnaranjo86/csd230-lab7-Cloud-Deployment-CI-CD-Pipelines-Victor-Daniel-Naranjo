class Magazine {
  final int id;
  final String title;
  final double price;
  final int copies;
  final int orderQty;
  final String currentIssue;

  Magazine({
    required this.id,
    required this.title,
    required this.price,
    required this.copies,
    required this.orderQty,
    required this.currentIssue,
  });

  factory Magazine.fromJson(Map<String, dynamic> json) {
    return Magazine(
      id: json['id'],
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      copies: json['copies'] ?? 0,
      orderQty: json['orderQty'] ?? 0,
      currentIssue: json['currentIssue'] ?? '',
    );
  }
}