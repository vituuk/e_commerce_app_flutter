import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/screens/orders/order_details_page.dart';

class KHQRPaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String qrString;
  final String deeplink;

  const KHQRPaymentPage({
    super.key,
    required this.orderData,
    required this.qrString,
    required this.deeplink,
  });

  @override
  State<KHQRPaymentPage> createState() => _KHQRPaymentPageState();
}

class _KHQRPaymentPageState extends State<KHQRPaymentPage> {
  Timer? _statusTimer;
  bool _isCheckingStatus = false;
  bool _isSuccess = false;
  int _secondsRemaining = 900; // 15 minutes expiration
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
        _statusTimer?.cancel();
        _showExpirationDialog();
      }
    });
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isCheckingStatus || _isSuccess) return;

      _isCheckingStatus = true;
      try {
        final orderId = widget.orderData['id'];
        final updatedOrder = await ApiService.getOrderDetails(orderId);
        
        if (updatedOrder['payment_status'] == 'completed') {
          timer.cancel();
          _countdownTimer?.cancel();
          setState(() {
            _isSuccess = true;
            _isCheckingStatus = false;
          });
          _handlePaymentSuccess();
        }
      } catch (e) {
        // Silent error to prevent UI disruption during polling
      } finally {
        _isCheckingStatus = false;
      }
    });
  }

  void _showExpirationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Expired'),
        content: const Text('The KHQR payment session has expired. Please place the order again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst); // Go home
            },
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 70),
            const SizedBox(height: 16),
            const Text(
              'Payment Received!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thank you, your order ${widget.orderData['order_number']} has been successfully paid.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                      builder: (_) => OrderDetailsPage(orderId: widget.orderData['id']),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'View Order Details',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchABAMobile() async {
    final uri = Uri.parse(widget.deeplink);
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Successfully launched
      } else {
        _showDeeplinkError();
      }
    } catch (e) {
      _showDeeplinkError();
    }
  }

  void _showDeeplinkError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open ABA Mobile app. Please scan the QR code instead.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primaryColor = const Color(0xFF4A7C59);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'KHQR Payment',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: onSurface),
          onPressed: () {
            // Confirm exit
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text('Are you sure you want to exit the payment screen? You can pay later from your order history.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Stay'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Exit payment
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expiration Countdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Expires in: ${_formatTime(_secondsRemaining)}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic KHQR Card Frame (High Fidelity)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header (KHQR Red Brand)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          'KHQR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Instructions Sub-header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.red.shade50,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Scan to Pay with any Cambodian Bank App',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // The QR Code
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: QrImageView(
                        data: widget.qrString,
                        version: QrVersions.auto,
                        size: 240.0,
                        embeddedImage: const AssetImage('lib/assets/image/google.png'), // Fallback embedded image if any, otherwise just clean QR
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(30, 30),
                        ),
                        errorStateBuilder: (cxt, err) {
                          return const Center(
                            child: Text(
                              "Failed to generate QR Code",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),

                    // Footer logos placeholder (Bakong & ABA Pay)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance, color: Colors.blue.shade900, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'ABA PAYWAY SECURE',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount & Details Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Number',
                          style: TextStyle(color: onSurface.withOpacity(0.55), fontSize: 14),
                        ),
                        Text(
                          widget.orderData['order_number'],
                          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(color: onSurface.withOpacity(0.55), fontSize: 14),
                        ),
                        Text(
                          '\$${widget.orderData['total']}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Deeplink Button for ABA Mobile App
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _launchABAMobile,
                  icon: const Icon(Icons.phone_android, color: Colors.white),
                  label: const Text(
                    'Pay in ABA Mobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1), // ABA Bank Blue color
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status check loading indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Waiting for your payment...',
                    style: TextStyle(
                      color: onSurface.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
