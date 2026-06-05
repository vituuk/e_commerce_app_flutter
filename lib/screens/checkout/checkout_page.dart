import 'package:flutter/material.dart';
import 'package:lesson_flutter/services/cart_service.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/models/customer.dart';
import 'package:lesson_flutter/screens/profile/customer_profile_page.dart';
import 'package:lesson_flutter/screens/orders/order_details_page.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Customer? customer;
  bool isLoadingProfile = true;
  bool isPlacingOrder = false;
  String selectedPaymentMethod = 'credit_card';

  @override
  void initState() {
    super.initState();
    loadCustomerProfile();
  }

  Future<void> loadCustomerProfile() async {
    setState(() => isLoadingProfile = true);

    try {
      final profileData = await ApiService.getCustomerProfile();
      setState(() {
        if (profileData != null) {
          customer = Customer.fromJson(profileData);
        }
        isLoadingProfile = false;
      });
    } catch (e) {
      setState(() => isLoadingProfile = false);
    }
  }

  Future<void> placeOrder() async {
    final cartService = Provider.of<CartService>(context, listen: false);

    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if customer profile exists
    if (customer == null) {
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shipping Address Required'),
          content: const Text(
              'Please add your shipping address before placing an order.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add Address'),
            ),
          ],
        ),
      );

      if (shouldCreate == true) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerProfilePage(),
          ),
        );
        await loadCustomerProfile();
      }
      return;
    }

    setState(() => isPlacingOrder = true);

    try {
      // Prepare order items
      final items = cartService.items.map((item) {
        return {
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'size': item.size,
          'color': item.color,
        };
      }).toList();

      // Create order
      final orderData = await ApiService.createOrder(
        paymentMethod: selectedPaymentMethod,
        items: items,
      );

      setState(() => isPlacingOrder = false);

      // Clear cart
      cartService.clearCart();

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ${orderData['order_number']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                            orderId: orderData['id'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        // Navigate back to home
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => isPlacingOrder = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartService = Provider.of<CartService>(context);

    // Calculate totals
    final subtotal = cartService.totalPrice;
    final tax = subtotal * 0.10; // 10% tax
    final total = subtotal + tax;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Section
                  _buildSectionTitle('Shipping Address', theme),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerProfilePage(),
                          ),
                        );
                        await loadCustomerProfile();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: customer == null
                            ? Row(
                                children: [
                                  Icon(Icons.add_location_alt_outlined,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Add Shipping Address',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        customer!.fullName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CustomerProfilePage(),
                                            ),
                                          );
                                          await loadCustomerProfile();
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (customer!.phone != null)
                                    Text(
                                      customer!.phone!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer!.fullAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Section
                  _buildSectionTitle('Payment Method', theme),
                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    'credit_card',
                    'Credit Card',
                    Icons.credit_card,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    'paypal',
                    'PayPal',
                    Icons.account_balance_wallet,
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    'google_pay',
                    'Google Pay',
                    Icons.payment,
                    theme,
                  ),

                  const SizedBox(height: 24),

                  // Order Summary Section
                  _buildSectionTitle('Order Summary', theme),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            'Items (${cartService.itemCount})',
                            '\$${subtotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow(
                            'Tax (10%)',
                            '\$${tax.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'Total',
                            '\$${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPlacingOrder ? null : placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isPlacingOrder
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Place Order (\$${total.toStringAsFixed(2)})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = selectedPaymentMethod == value;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black,
          ),
        ),
      ],
    );
  }
}
