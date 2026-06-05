import 'package:flutter/material.dart';

class CartItemCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String size;
  final int initialQuantity;
  final VoidCallback? onDelete;
  final Function(int)? onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.size,
    this.initialQuantity = 1,
    this.onDelete,
    this.onQuantityChanged,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.colorScheme.surface : Colors.grey[100]!;
    final imgBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 30,
              height: 60,
              color: imgBg,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, color: onSurface.withOpacity(0.4));
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
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
                  '\$${widget.price.toStringAsFixed(2)} • ${widget.size}',
                  style: TextStyle(
                    fontSize: 12,
                    color: onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            icon: Icon(Icons.delete_outline, color: onSurface.withOpacity(0.7)),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class CartItemCardWithQuantity extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String size;
  final String? color;
  final int initialQuantity;
  final VoidCallback? onDelete;
  final Function(int)? onQuantityChanged;

  const CartItemCardWithQuantity({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.size,
    this.color,
    this.initialQuantity = 1,
    this.onDelete,
    this.onQuantityChanged,
  });

  @override
  State<CartItemCardWithQuantity> createState() => _CartItemCardWithQuantityState();
}

class _CartItemCardWithQuantityState extends State<CartItemCardWithQuantity> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
      widget.onQuantityChanged?.call(quantity);
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        widget.onQuantityChanged?.call(quantity);
      });
    }
  }

  // Helper function to parse hex color string to Color
  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // Helper function to get color name from hex
  String _getColorName(String colorHex) {
    final colorMap = {
      '#000000': 'Black',
      '#FFFFFF': 'White',
      '#F44336': 'Red',
      '#E91E63': 'Pink',
      '#9C27B0': 'Purple',
      '#673AB7': 'Deep Purple',
      '#3F51B5': 'Indigo',
      '#2196F3': 'Blue',
      '#03A9F4': 'Light Blue',
      '#00BCD4': 'Cyan',
      '#009688': 'Teal',
      '#4CAF50': 'Green',
      '#8BC34A': 'Light Green',
      '#CDDC39': 'Lime',
      '#FFEB3B': 'Yellow',
      '#FFC107': 'Amber',
      '#FF9800': 'Orange',
      '#FF5722': 'Deep Orange',
      '#795548': 'Brown',
      '#9E9E9E': 'Grey',
      '#607D8B': 'Blue Grey',
    };
    return colorMap[colorHex.toUpperCase()] ?? 'Color';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.colorScheme.surface : Colors.grey[100]!;
    final imgBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final btnBg = isDark ? const Color(0xFF2E2E2E) : Colors.white;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: imgBg,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image, color: onSurface.withOpacity(0.4));
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
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
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                // Size and Color row
                Row(
                  children: [
                    if (widget.size.isNotEmpty) ...[
                      Icon(Icons.straighten, size: 12, color: onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        widget.size,
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                    if (widget.color != null && widget.color!.isNotEmpty) ...[
                      if (widget.size.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: onSurface.withOpacity(0.3))),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(widget.color!),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: onSurface.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getColorName(widget.color!),
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 18, color: onSurface),
                onPressed: _decrementQuantity,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: btnBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 18, color: onSurface),
                onPressed: _incrementQuantity,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: btnBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Delete Button
          IconButton(
            icon: Icon(Icons.delete_outline, color: onSurface.withOpacity(0.7)),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class CostSummary extends StatelessWidget {
  final double subtotal;
  final double taxesAndFees;

  const CostSummary({
    super.key,
    required this.subtotal,
    required this.taxesAndFees,
  });

  double get total => subtotal + taxesAndFees;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey[300]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxes & Other Fees',
                style: TextStyle(
                  fontSize: 14,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '\$${taxesAndFees.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
