import 'package:flutter/foundation.dart';
import 'package:lesson_flutter/models/favorite.dart';
import 'package:lesson_flutter/models/product.dart';
import 'package:lesson_flutter/services/api_service.dart';

class FavoriteItem {
  final int favoriteId; // ID from favorites table
  final int productId;
  final String title;
  final String imageUrl;
  final double price;
  final String category;

  FavoriteItem({
    required this.favoriteId,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.category,
  });

  factory FavoriteItem.fromFavorite(Favorite favorite) {
    final product = favorite.product!;
    return FavoriteItem(
      favoriteId: favorite.id,
      productId: product.id,
      title: product.title,
      imageUrl: product.images.isNotEmpty ? product.images.first : '',
      price: product.price.toDouble(),
      category: product.category?.name ?? 'Unknown',
    );
  }
}

class FavoriteService extends ChangeNotifier {
  final List<FavoriteItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<FavoriteItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check if a product is in favorites (by product ID)
  bool isFavorite(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Get favorite ID for a product (returns null if not favorited)
  int? getFavoriteId(int productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId).favoriteId;
    } catch (e) {
      return null;
    }
  }

  /// Load favorites from backend (only for logged-in users)
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await ApiService.getAuthToken();
      if (token == null) {
        // Guest mode — keep whatever is already in memory (do NOT clear!)
        // Items were added via addToFavorites() and stored temporarily.
        _isLoading = false;
        notifyListeners();
        debugPrint('ℹ️ Guest mode: Keeping ${_items.length} in-memory favorites');
        return;
      }

      // Logged in - load from backend database
      final response = await ApiService.getFavorites();
      _items.clear();
      
      for (var item in response) {
        final favorite = Favorite.fromJson(item);
        if (favorite.product != null) {
          _items.add(FavoriteItem.fromFavorite(favorite));
        }
      }
      
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Loaded ${_items.length} favorites from database');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error loading favorites: $e');
    }
  }

  /// Toggle favorite status (add or remove)
  /// For guests: pass product details to store temporarily
  Future<bool> toggleFavorite(
    int productId, {
    String? title,
    String? imageUrl,
    double? price,
    String? category,
  }) async {
    if (isFavorite(productId)) {
      return await removeFromFavorites(productId);
    } else {
      return await addToFavorites(
        productId,
        title: title,
        imageUrl: imageUrl,
        price: price,
        category: category,
      );
    }
  }

  /// Add product to favorites (backend API if logged in, temporary memory if guest)
  Future<bool> addToFavorites(
    int productId, {
    String? title,
    String? imageUrl,
    double? price,
    String? category,
  }) async {
    try {
      final token = await ApiService.getAuthToken();
      
      if (token == null) {
        // Guest mode - add to temporary memory only (will be cleared on refresh)
        debugPrint('⚠️ Guest mode: Adding to temporary favorites (not persisted)');
        
        // Check if already in favorites
        if (isFavorite(productId)) {
          debugPrint('⚠️ Product $productId already in guest favorites');
          return true;
        }
        
        // Add to temporary list with provided details
        final tempItem = FavoriteItem(
          favoriteId: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          productId: productId,
          title: title ?? 'Product $productId',
          imageUrl: imageUrl ?? '',
          price: price ?? 0.0,
          category: category ?? 'Unknown',
        );
        
        _items.add(tempItem);
        notifyListeners();
        
        debugPrint('✅ Added to guest favorites (temporary): $title');
        return true;
      }

      // Logged in - save to backend database (permanent)
      await ApiService.addToFavorites(productId);
      
      // Reload favorites from backend to get updated list
      await loadFavorites();
      
      debugPrint('✅ Added to favorites (saved to database): Product $productId');
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove from favorites (backend API if logged in, temporary memory if guest)
  Future<bool> removeFromFavorites(int productId) async {
    try {
      final token = await ApiService.getAuthToken();
      
      if (token == null) {
        // Guest mode - remove from temporary memory only
        debugPrint('⚠️ Guest mode: Removing from temporary favorites');
        _items.removeWhere((item) => item.productId == productId);
        notifyListeners();
        return true;
      }

      // Logged in - remove from backend database (permanent)
      final favoriteId = getFavoriteId(productId);
      if (favoriteId == null) {
        debugPrint('⚠️ Product $productId not in favorites');
        return false;
      }

      await ApiService.removeFromFavorites(favoriteId);
      
      // Remove from local list
      _items.removeWhere((item) => item.productId == productId);
      notifyListeners();
      
      debugPrint('✅ Removed from favorites (deleted from database): Product $productId');
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Error removing from favorites: $e');
      return false;
    }
  }

  /// Clear all favorites (local only - for logout)
  void clearFavorites() {
    _items.clear();
    notifyListeners();
  }
}
