import 'package:flutter/material.dart';
import 'package:lesson_flutter/models/product.dart';
import 'package:lesson_flutter/models/category.dart' as model;
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/screens/home-page/product-card.dart';
import 'package:lesson_flutter/widgets/skeleton_loader.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 0;

  List<model.Category> _categories = [];
  List<Product> _products = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _errorMessage = 'Failed to load categories';
        });
      }
    }
  }

  /// Checks if a URL points to a real image (not a placeholder or broken link)
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    if (lower.contains('placehold.co') ||
        lower.contains('placeimg.com') ||
        lower.contains('pravatar.cc') ||
        lower.contains('lorempixel.com') ||
        lower.contains('loremflickr.com') ||
        // Removed picsum.photos from filter - it's a valid image service
        lower == 'https://google.com' ||
        lower == 'https://www.google.com' ||
        lower == 'https://www.google.com/' ||
        lower == 'http://google.com') {
      return false;
    }
    return true;
  }

  Future<void> _loadProducts() async {
    try {
      print('🔄 Loading products...');
      final products = await ApiService.fetchProducts();
      print('✅ Received ${products.length} products from API');
      
      final validProducts = products
          .where((p) => _isValidImageUrl(p.primaryImage))
          .toList();
      print('✅ ${validProducts.length} products passed image validation');
      
      if (mounted) {
        setState(() {
          _products = validProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _errorMessage = 'Failed to load products: $e';
        });
      }
    }
  }

  Future<void> _onCategorySelected(int index) async {
    setState(() {
      _selectedIndex = index;
      _isLoadingProducts = true;
    });

    try {
      List<Product> products;
      if (index == 0) {
        // "All" category — fetch all products
        products = await ApiService.fetchProducts();
      } else {
        // Fetch filtered by category ID
        final category = _categories[index - 1]; // offset by 1 for "All"
        products = await ApiService.fetchProductsByCategory(category.id);
      }

      if (mounted) {
        setState(() {
          _products = products
              .where((p) => _isValidImageUrl(p.primaryImage))
              .toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _errorMessage = 'Failed to load products';
        });
      }
    }
  }

  Widget _buildCategoryChip(BuildContext context, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipBg = isSelected
        ? theme.colorScheme.primary
        : (isDark ? theme.colorScheme.surface : Colors.white);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.shade200;
    final labelColor = isSelected
        ? Colors.white
        : theme.colorScheme.onSurface.withOpacity(0.65);

    // index 0 = "All", the rest map to API categories
    final String label;
    final String icon;
    if (index == 0) {
      label = 'All';
      icon = '🌐';
    } else {
      final category = _categories[index - 1];
      label = category.name;
      // Assign icons based on category name
      switch (category.name.toLowerCase()) {
        case 'clothes':
        case 'updated category name':
          icon = '👕';
          break;
        case 'electronics':
          icon = '📱';
          break;
        case 'furniture':
          icon = '🪑';
          break;
        case 'shoes':
          icon = '👟';
          break;
        case 'miscellaneous':
          icon = '📦';
          break;
        default:
          icon = '🏷️';
      }
    }

    return GestureDetector(
      onTap: () => _onCategorySelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final headerBg = isDark ? theme.colorScheme.surface : Colors.grey.shade50;

    if (_errorMessage != null && _products.isEmpty && _categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: onSurface.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                style: TextStyle(color: onSurface.withOpacity(0.6), fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoadingCategories = true;
                  _isLoadingProducts = true;
                });
                _loadData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Total chip count = 1 (All) + categories.length
    final totalChipCount = 1 + _categories.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories Header + Chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: headerBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    Icon(Icons.more_horiz, color: onSurface.withOpacity(0.6)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: _isLoadingCategories
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 5,
                        itemBuilder: (context, index) => const CategoryChipSkeleton(),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: totalChipCount,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _buildCategoryChip(context, index),
                      ),
              ),
            ],
          ),
        ),
        // Product Cards Grid — shrinkWrap so the outer scroll handles everything
        _isLoadingProducts
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const ProductCardSkeleton(),
              )
            : _products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: onSurface.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No products found',
                          style: TextStyle(
                              color: onSurface.withOpacity(0.6), fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isClothing =
                          product.category.name.toLowerCase() == 'clothes' ||
                          product.category.name.toLowerCase() == 'clothing' ||
                          product.category.name.toLowerCase() == 'updated category name';

                      final titleLower = product.title.toLowerCase();
                      final needsSize = isClothing &&
                          !titleLower.contains('cap') &&
                          !titleLower.contains('hat') &&
                          !titleLower.contains('bag') &&
                          !titleLower.contains('backpack') &&
                          !titleLower.contains('wallet') &&
                          !titleLower.contains('belt') &&
                          !titleLower.contains('scarf') &&
                          !titleLower.contains('glove') &&
                          !titleLower.contains('sock');

                      return ProductCard(
                        productId: product.id,
                        imageUrl: product.primaryImage,
                        title: product.title,
                        subtitle: product.category.name,
                        price: product.price,
                        brand: product.category.name,
                        description: product.description,
                        originalPrice: isClothing ? (product.price * 1.33).toDouble() : null,
                        discountPercent: isClothing ? 25 : null,
                        sizes: ['S', 'M', 'L', 'XL'],
                        colors: [Colors.black, Colors.red, Colors.blue],
                      );
                    },
                  ),
      ],
    );
  }
}