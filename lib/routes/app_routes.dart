// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../pages/routes/home-page.dart';
import '../pages/routes/second-page.dart';
import '../pages/routes/detail-page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Named Routes App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
        '/details': (context) => const DetailsScreen(),
      },
    );
  }
}