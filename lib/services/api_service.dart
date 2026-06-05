import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lesson_flutter/models/category.dart';
import 'package:lesson_flutter/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Laravel backend URL - automatically selects based on platform
  // For Web (Chrome/Edge): http://localhost:8000/api
  // For Android Emulator: http://10.0.2.2:8000/api
  // For iOS Simulator: http://localhost:8000/api  
  // For Physical Device: http://YOUR_COMPUTER_IP:8000/api (change this!)
  
  // Reads API_BASE_URL from .env file
  // Set this to your Render backend URL in .env:
  //   API_BASE_URL=https://your-app.onrender.com/api
  static String get _productionUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  static String get _baseUrl {
    if (kIsWeb) {
      // Web (Vercel deploy) → uses API_BASE_URL from .env
      return _productionUrl;
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:8000/api';
    } else {
      // Fallback (desktop / physical device)
      return _productionUrl;
    }
  }

  
  static String? _authToken;

  /// Get auth token from storage
  static Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  /// Save auth token to storage
  static Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Save user data to storage
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user['name'] ?? '');
    await prefs.setString('user_email', user['email'] ?? '');
    await prefs.setString('user_role', user['role'] ?? 'user');
  }

  /// Get user data from storage
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'role': prefs.getString('user_role'),
    };
  }

  /// Clear auth token
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  /// Get headers with auth token if available
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'user', // Default to 'user', can be 'admin'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveAuthToken(data['token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveAuthToken(data['token']);
        await saveUserData(data['user']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: headers,
      );
    } finally {
      await clearAuthToken();
    }
  }

  /// Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user');
    }
  }

  /// Fetch categories (Public - No auth required)
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  /// Fetch all products (Public - No auth required)
  static Future<List<Product>> fetchProducts({int page = 1, int perPage = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?page=$page&per_page=$perPage'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> products = data is List ? data : (data['data'] ?? []);
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  /// Fetch products by category
  static Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?category_id=$categoryId'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> products = data is List ? data : (data['data'] ?? []);
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products for category $categoryId');
    }
  }

  /// Search products
  static Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?search=$query'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> products = data is List ? data : (data['data'] ?? []);
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }

  /// Add item to cart (requires authentication)
  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cart'),
      headers: await _getHeaders(),
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to cart');
    }
  }

  /// Get cart items
  static Future<List<dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cart'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['items'] ?? []);
    } else {
      throw Exception('Failed to get cart');
    }
  }

  /// Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem(int itemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/cart/$itemId'),
      headers: await _getHeaders(),
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update cart item');
    }
  }

  /// Remove item from cart
  static Future<void> removeFromCart(int itemId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cart/$itemId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove from cart');
    }
  }

  /// Clear cart
  static Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cart'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to clear cart');
    }
  }

  /// Add to favorites
  static Future<Map<String, dynamic>> addToFavorites(int productId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/favorites'),
      headers: await _getHeaders(),
      body: json.encode({'product_id': productId}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to favorites');
    }
  }

  /// Get favorites
  static Future<List<dynamic>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/favorites'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['favorites'] ?? []);
    } else {
      throw Exception('Failed to get favorites');
    }
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/favorites/$favoriteId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove from favorites');
    }
  }

  /// Create order
  static Future<Map<String, dynamic>> createOrder({
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: await _getHeaders(),
      body: json.encode({
        'payment_method': paymentMethod,
        'items': items,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create order');
    }
  }

  /// Get user orders
  static Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : (data['orders'] ?? []);
    } else {
      throw Exception('Failed to get orders');
    }
  }

  /// Get order details
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get order details');
    }
  }

  /// Cancel an order (delete if pending)
  static Future<void> cancelOrder(int orderId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Failed to cancel order');
    }
  }

  // ───────────────── CUSTOMER PROFILE ─────────────────

  /// Get the current user's customer profile
  static Future<Map<String, dynamic>?> getCustomerProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data is List ? data : (data['data'] ?? []);
        if (list.isNotEmpty) return list.first;
        return null;
      }
    } catch (_) {}
    return null;
  }

  /// Create customer profile
  static Future<Map<String, dynamic>> createCustomerProfile(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/customers'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    }
    final err = json.decode(response.body);
    throw Exception(err['message'] ?? 'Failed to create customer profile');
  }

  /// Update customer profile
  static Future<Map<String, dynamic>> updateCustomerProfile(
      int customerId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/customers/$customerId'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    final err = json.decode(response.body);
    throw Exception(err['message'] ?? 'Failed to update customer profile');
  }
}

