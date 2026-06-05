import 'package:flutter/material.dart';
import 'package:lesson_flutter/utils/detail-card.dart';
import 'package:lesson_flutter/services/cart_service.dart';
import 'package:lesson_flutter/services/favorite_service.dart';
import 'package:lesson_flutter/services/auth_helper.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final int productId;
  final String imageUrl;
  final String title;
  final String subtitle;
  final int price;
  final String? brand;
  final bool? isVerified;
  final double? rating;
  final double? originalPrice;
  final int? discountPercent;
  final List<String>? sizes;
  final List<Color>? colors;
  final String? description;

  const ProductCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.brand,
    this.isVerified,
    this.rating,
    this.originalPrice,
    this.discountPercent,
    this.sizes,
    this.colors,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.colorScheme.surface : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade200;
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCard(
              productId: productId,
              imageUrl: imageUrl,
              brand: brand ?? 'H&M',
              isVerified: isVerified ?? true,
              rating: rating ?? 4.3,
              title: title,
              price: price.toDouble(),
              originalPrice: originalPrice,
              discountPercent: discountPercent,
              sizes: sizes,
              colors: colors ?? [Colors.black, Colors.red, Colors.blue],
              description: description ??
                'Stay stylish with this $title. Featuring premium quality materials and modern design, this product is perfect for any occasion. Comfortable fit and durable construction ensure long-lasting wear.',
              category: subtitle,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              // Title + Category + Price + Add to Cart
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$$price',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        Consumer<FavoriteService>(
                          builder: (context, favoriteService, child) {
                            final isFavorite = favoriteService.isFavorite(productId);
                            return GestureDetector(
                              onTap: () async {
                                // Allow guests to favorite (local storage)
                                // Show loading indicator
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing...'),
                                    duration: Duration(milliseconds: 500),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                 try {
                                  // Toggle favorite (works for both guest and logged-in users)
                                  final success = await favoriteService.toggleFavorite(
                                    productId,
                                    title: title,
                                    imageUrl: imageUrl,
                                    price: price.toDouble(),
                                    category: subtitle,
                                  );

                                  // Check if guest
                                  final token = await ApiService.getAuthToken();
                                  final isGuest = token == null || token.isEmpty;
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    if (success && !isFavorite && isGuest) {
                                      // Guest added to favorites — show hint to login
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.info_outline, color: Colors.white, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '$title saved temporarily. Login to keep forever!',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF4A7C59),
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? (isFavorite
                                                    ? '$title removed from favorites'
                                                    : '$title added to favorites')
                                                : 'Failed to update favorites. Please try again.',
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: success ? null : Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  debugPrint('❌ Error toggling favorite: $e');
                                }
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFavorite ? Colors.red : onSurface.withOpacity(0.5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          // Allow guests to add to cart (local storage)
                          final cartService = Provider.of<CartService>(context, listen: false);
                          cartService.addItem(
                            productId: productId,
                            title: title,
                            imageUrl: imageUrl,
                            price: price.toDouble(),
                            category: subtitle,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$title added to cart'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
