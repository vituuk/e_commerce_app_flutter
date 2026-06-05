class CartItem {
  final int productId;
  final String title;
  final String imageUrl;
  final double price;
  final String category;
  final String? size;
  final String? color;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.size,
    this.color,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      category: json['category'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'] ?? 1,
    );
  }
}
