import 'package:flutter/material.dart';
import 'package:lesson_flutter/services/cart_service.dart';
import 'package:lesson_flutter/services/favorite_service.dart';
import 'package:lesson_flutter/services/auth_helper.dart';
import 'package:lesson_flutter/screens/home-page.dart';
import 'package:provider/provider.dart';

class DetailCard extends StatefulWidget {
  final int productId;
  final String imageUrl;
  final String brand;
  final bool isVerified;
  final double rating;
  final String title;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final List<String>? sizes;
  final List<Color> colors;
  final String description;
  final String category;

  const DetailCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.brand,
    this.isVerified = false,
    required this.rating,
    required this.title,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.sizes,
    required this.colors,
    required this.description,
    required this.category,
  });

  @override
  State<DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<DetailCard> {
  String? selectedSize;
  Color? selectedColor;
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;
    final imgBg = isDark ? surface : Colors.grey[100]!;
    final borderColor = isDark ? const Color(0xFF444444) : Colors.grey[300]!;
    final subtleText = onSurface.withOpacity(0.6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoriteService>(
            builder: (context, favoriteService, child) {
              final isFavorite = favoriteService.isFavorite(widget.productId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : onSurface,
                ),
                onPressed: () async {
                  // Allow guests to favorite (local storage)
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing...'),
                      duration: Duration(milliseconds: 500),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Toggle favorite (works for both guest and logged-in users)
                  final success = await favoriteService.toggleFavorite(
                    widget.productId,
                    title: widget.title,
                    imageUrl: widget.imageUrl,
                    price: widget.price,
                    category: widget.category,
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? (isFavorite
                                  ? '${widget.title} removed from favorites'
                                  : '${widget.title} added to favorites')
                              : 'Failed to update favorites. Please try again.',
                        ),
                        backgroundColor: success ? null : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: imgBg,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image, size: 100, color: subtleText),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand and Rating
                        Row(
                          children: [
                            Text(
                              widget.brand,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            if (widget.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                            const Spacer(),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Product Title
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Price
                        Row(
                          children: [
                            Text(
                              '\$${widget.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '\$${widget.originalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: subtleText,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            if (widget.discountPercent != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${widget.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Color Selector
                        Row(
                          children: [
                            Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                children: widget.colors.map((color) {
                                  final isSelected = selectedColor == color;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Size Selector
                        if (widget.sizes != null && widget.sizes!.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'Size',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: widget.sizes!.map((size) {
                                    final isSelected = selectedSize == size;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSize = size;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.scaffoldBackgroundColor,
                                          border: Border.all(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : borderColor,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.description,
                              maxLines: isDescriptionExpanded ? null : 3,
                              overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: subtleText,
                                height: 1.5,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isDescriptionExpanded = !isDescriptionExpanded;
                                });
                              },
                              child: Text(
                                isDescriptionExpanded ? 'Read Less' : 'Read More',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button - Add to Cart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Guests can add to cart (temporary, memory only)
                  // Logged-in users will sync with backend
                  final cartService = Provider.of<CartService>(context, listen: false);
                  
                  // Convert color to hex string (e.g., "#FF0000" for red)
                  String? colorHex;
                  if (selectedColor != null) {
                    colorHex = '#${selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}';
                  }
                  
                  cartService.addItem(
                    productId: widget.productId,
                    title: widget.title,
                    imageUrl: widget.imageUrl,
                    price: widget.price,
                    category: widget.category,
                    size: selectedSize,
                    color: colorHex,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('${widget.title} added to cart!'),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF4A7C59),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context); // Go back to previous page
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
