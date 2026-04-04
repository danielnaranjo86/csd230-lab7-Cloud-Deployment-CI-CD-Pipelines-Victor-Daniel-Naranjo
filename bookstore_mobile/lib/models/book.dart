class Book {
  final int id;
  final String title;
  final String author;
  final double price;
  final int? copies;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.copies,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      copies: json['copies']?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'copies': copies ?? 10,
    };
  }
}