import 'package:flutter/material.dart';
import 'package:lesson_flutter/screens/home-page.dart';
import 'package:lesson_flutter/screens/auth/login.dart';
import 'package:lesson_flutter/screens/auth/register.dart';
import 'package:lesson_flutter/pages/routes/second-page.dart';
import 'package:lesson_flutter/pages/routes/detail-page.dart';
import 'package:lesson_flutter/services/cart_service.dart';
import 'package:lesson_flutter/services/favorite_service.dart';
import 'package:lesson_flutter/theme/app_theme.dart';
import 'package:lesson_flutter/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => FavoriteService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'UI Design Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const MyHomePage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/second': (context) => const SecondScreen(),
              '/details': (context) => const DetailsScreen(),
            },
          );
        },
      ),
    );
  }
}
