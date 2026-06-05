import 'package:flutter/material.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/screens/auth/login.dart';
import 'package:lesson_flutter/screens/auth/register.dart';

class AuthHelper {
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Show login/register prompt dialog
  static Future<bool> showLoginPrompt(BuildContext context, {String? message}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: Text(
          message ?? 'Please login or register to continue with this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: const Text('Register'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Check auth and show prompt if not logged in
  /// Returns true if user is logged in, false otherwise
  static Future<bool> requireAuth(BuildContext context, {String? message}) async {
    final loggedIn = await isLoggedIn();
    if (!loggedIn) {
      await showLoginPrompt(context, message: message);
      return false;
    }
    return true;
  }
}
