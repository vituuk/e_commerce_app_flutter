import 'package:lesson_flutter/models/category.dart';

class Product {
  final int id;
  final String title;
  final String slug;
  final int price;
  final String description;
  final Category category;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      price: _parsePrice(json['price']),
      description: json['description'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Parse price from various formats (String, int, double)
  static int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.toInt();
    if (price is String) {
      final parsed = double.tryParse(price);
      return parsed?.toInt() ?? 0;
    }
    return 0;
  }

  /// Returns the first valid image URL or empty string
  String get primaryImage => images.isNotEmpty ? images.first : '';
}
