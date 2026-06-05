import 'package:flutter/material.dart';
import 'package:lesson_flutter/pages/routes/detail-page.dart';

class MyNav extends StatelessWidget {
  const MyNav({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Scaffold(
              appBar: AppBar(title: const Text('flutter')),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate with data
                    Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: {'id': 101, 'name': 'Product Name'},
                    );
                  },
                  child: const Text('Go to Details'),
                ),
              ),
            ),
        '/details': (context) => DetailsScreen(),
      },
    );
  }
}
