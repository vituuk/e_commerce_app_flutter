import 'package:flutter/material.dart';
import 'package:lesson_flutter/utils/new-card.dart';
import 'package:lesson_flutter/services/cart_service.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/screens/orders/order_history_page.dart';
import 'package:lesson_flutter/screens/orders/order_details_page.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int? selectedCardIndex;
  String? selectedOtherMethod;
  List<Map<String, dynamic>> userCards = [];
  bool _isSubmitting = false;

  // Map selection → backend payment_method value
  String get _paymentMethodValue {
    if (selectedOtherMethod == 'paypal') return 'paypal';
    if (selectedOtherMethod == 'googlepay') return 'google_pay';
    return 'credit_card';
  }

  Future<void> _submitOrder(BuildContext context) async {
    if (selectedCardIndex == null && selectedOtherMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build items payload
      final items = cartService.items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        if (item.size != null) 'size': item.size,
        if (item.color != null) 'color': item.color,
      }).toList();

      // Submit order to backend
      final orderData = await ApiService.createOrder(
        paymentMethod: _paymentMethodValue,
        items: items,
      );

      // Clear local cart
      cartService.clearCart();

      if (!mounted) return;

      // Navigate to order details screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailsPage(orderId: orderData['id']),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.appBarTheme.backgroundColor ?? scaffoldBg;
    final cardBg = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey[300]!;
    final subtleText = onSurface.withOpacity(0.55);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
            ),
            icon: Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary, size: 18),
            label: Text(
              'Orders',
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Consumer<CartService>(
                      builder: (context, cartService, _) => _OrderSummaryCard(
                        cartService: cartService,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        onSurface: onSurface,
                        subtleText: subtleText,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Card Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Credit Card',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: subtleText)),
                        Text('${2 + userCards.length} Cards',
                          style: TextStyle(fontSize: 13, color: subtleText)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => setState(() {
                        selectedCardIndex = 0;
                        selectedOtherMethod = null;
                      }),
                      child: CreditCardWidget(
                        cardNumber: '**** 4236',
                        cardHolder: 'Stanly Weber',
                        expiryDate: '08/25',
                        gradientColors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        isSelected: selectedCardIndex == 0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => setState(() {
                        selectedCardIndex = 1;
                        selectedOtherMethod = null;
                      }),
                      child: CreditCardWidget(
                        cardNumber: '**** 1357',
                        cardHolder: 'Stanly Weber',
                        expiryDate: '08/25',
                        gradientColors: const [Color(0xFF581C87), Color(0xFF9333EA)],
                        isSelected: selectedCardIndex == 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...userCards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      final cardIndex = index + 2;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              selectedCardIndex = cardIndex;
                              selectedOtherMethod = null;
                            }),
                            child: CreditCardWidget(
                              cardNumber:
                                  '**** ${card['cardNumber'].toString().substring(card['cardNumber'].toString().length - 4)}',
                              cardHolder: card['cardHolder'],
                              expiryDate: card['expiryDate'],
                              gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
                              isSelected: selectedCardIndex == cardIndex,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    // Add New Card Button
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddNewCardPage()),
                        );
                        if (!mounted) return;
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            userCards.add(result);
                            selectedCardIndex = userCards.length + 1;
                            selectedOtherMethod = null;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Add New Card',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Other Methods
                    Text('Others',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: subtleText)),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => setState(() {
                        selectedCardIndex = null;
                        selectedOtherMethod = 'paypal';
                      }),
                      child: PaymentMethodWidget(
                        label: 'PayPal',
                        iconText: 'P',
                        iconColor: const Color(0xFF003087),
                        backgroundColor: const Color(0xFFE3F2FD),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isSelected: selectedOtherMethod == 'paypal',
                        labelColor: onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => setState(() {
                        selectedCardIndex = null;
                        selectedOtherMethod = 'googlepay';
                      }),
                      child: PaymentMethodWidget(
                        label: 'Google Pay',
                        iconText: 'G',
                        iconColor: Colors.red,
                        backgroundColor: const Color(0xFFFFEBEE),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isSelected: selectedOtherMethod == 'googlepay',
                        labelColor: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pay Now Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scaffoldBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Consumer<CartService>(
              builder: (context, cartService, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pay Now — \$${cartService.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Order Summary Card ───────────────────
class _OrderSummaryCard extends StatelessWidget {
  final CartService cartService;
  final Color cardBg;
  final Color borderColor;
  final Color onSurface;
  final Color subtleText;

  const _OrderSummaryCard({
    required this.cartService,
    required this.cardBg,
    required this.borderColor,
    required this.onSurface,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: onSurface)),
          const SizedBox(height: 12),
          ...cartService.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('${item.title} ×${item.quantity}',
                    style: TextStyle(fontSize: 13, color: onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                ),
                Text('\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onSurface)),
              ],
            ),
          )),
          Divider(color: borderColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(color: subtleText, fontSize: 13)),
              Text('\$${cartService.subtotal.toStringAsFixed(2)}',
                style: TextStyle(color: onSurface, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (10%)', style: TextStyle(color: subtleText, fontSize: 13)),
              Text('\$${cartService.taxesAndFees.toStringAsFixed(2)}',
                style: TextStyle(color: onSurface, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(color: onSurface, fontSize: 15, fontWeight: FontWeight.bold)),
              Text('\$${cartService.total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────── CreditCardWidget ───────────────────
class CreditCardWidget extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final List<Color> gradientColors;
  final bool isSelected;

  const CreditCardWidget({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.gradientColors,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.green, width: 3) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Credit Card',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Text(cardNumber,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cardHolder,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 32,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(width: 32, height: 32,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        Positioned(left: 20,
                          child: Container(width: 32, height: 32,
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(expiryDate, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────── PaymentMethodWidget ───────────────────
class PaymentMethodWidget extends StatelessWidget {
  final String label;
  final String iconText;
  final Color iconColor;
  final Color backgroundColor;
  final Color cardBg;
  final Color borderColor;
  final Color labelColor;
  final bool isSelected;

  const PaymentMethodWidget({
    super.key,
    required this.label,
    required this.iconText,
    required this.iconColor,
    required this.backgroundColor,
    required this.cardBg,
    required this.borderColor,
    required this.labelColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(iconText,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: iconColor)),
            ),
          ),
          const SizedBox(width: 16),
          Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: labelColor)),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ],
      ),
    );
  }
}
