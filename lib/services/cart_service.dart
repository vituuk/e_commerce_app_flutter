import 'package:flutter/material.dart';
import 'package:lesson_flutter/models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get totalPrice => subtotal; // Alias for subtotal

  double get taxesAndFees => subtotal * 0.1; // 10% tax

  double get total => subtotal + taxesAndFees;

  void addItem({
    required int productId,
    required String title,
    required String imageUrl,
    required double price,
    required String category,
    String? size,
    String? color,
  }) {
    // Check if item already exists with same size and color
    final existingIndex = _items.indexWhere(
      (item) =>
          item.productId == productId &&
          item.size == size &&
          item.color == color,
    );

    if (existingIndex >= 0) {
      // Increment quantity if item exists
      _items[existingIndex].quantity++;
    } else {
      // Add new item
      _items.add(CartItem(
        productId: productId,
        title: title,
        imageUrl: imageUrl,
        price: price,
        category: category,
        size: size,
        color: color,
      ));
    }

    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length && quantity > 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
