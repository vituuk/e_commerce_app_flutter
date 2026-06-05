// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Header',
              style: TextStyle(
                color:Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          //    const Text(
          //   'Menu',
          //   style: TextStyle(
          //     color:Colors.white,
          //     fontSize: 25,
          //     fontWeight: FontWeight.bold,
          //     shadows: [
          //       Shadow(
          //         color:Colors.green,
          //         blurRadius: 5,
          //       )
          //     ]
          //   ),
          // ),
          ActionChip(
            label: const Text("Search"),
            backgroundColor: Colors.white,
            onPressed: (){},
            avatar: const Icon(LucideIcons.search, size: 25,weight: 200 ), 
          ),
//           SizedBox(
//        // Adjust this value to your liking
           
//   child: TextButton.icon(
//     onPressed: () {},
//     label: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),
//     icon: const Text("Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//     iconAlignment: IconAlignment.end,
//   ),
// ),
          ],
         
        ) 
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
              child: const Text("Go to Second Screen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: {
                    'id': 101,
                    'name': 'Product Name',
                  },
                );
              },
              child: const Text("Go to Details Screen"),
            ),
          ],
        ),
      ),
    );
  }
}