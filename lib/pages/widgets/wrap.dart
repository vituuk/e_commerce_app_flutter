import 'package:flutter/material.dart';

class WrapScreen extends StatelessWidget {
  const WrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tags = [
      'Flutter', 'Dart', 'Mobile', 'UI/UX', 'Firebase', 'API', 'State Management',
      'Responsive', 'Dark Mode', 'Animations', 'Kotlin', 'Swift'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Wrap Widget')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Popular Tags', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.deepPurple.shade50,
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {},
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}