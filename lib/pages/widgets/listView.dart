import 'package:flutter/material.dart';

class ListViewScreen extends StatelessWidget {
  const ListViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListView Example')),
      body: ListView.builder(
        itemCount: 20,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text('Item ${index + 1}'),
              subtitle: Text('This is description for item ${index + 1}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on Item ${index + 1}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}