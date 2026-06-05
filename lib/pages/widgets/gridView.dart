// import 'package:flutter/material.dart';

// class GridViewScreen extends StatelessWidget {
//   const GridViewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('GridView Example')),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 0.85,
//           ),
//           itemCount: 20,
//           itemBuilder: (context, index) {
//             return Card(
//               clipBehavior: Clip.antiAlias,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Image.network(
//                       'https://picsum.photos/id/${100 + index}/400/300',
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Product ${index + 1}',
//                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         const SizedBox(height: 4),
//                         Text('\$${(20 + index * 5)}.99', style: const TextStyle(color: Colors.green, fontSize: 18)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class GridViewScreen extends StatelessWidget {
  const GridViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GridView Example',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),

      body: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),

        children: List.generate(20, (index){
          return Padding(
             padding: const EdgeInsets.all(10),
             child: Container(
              // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
              color: Colors.green.shade100,
              child: Center(
                child: Text(
                    'Items $index', style: TextStyle(fontSize: 30, color: Colors.white
                ),
              ),
             ),
          ),
          );
        }),
      ),
      
    );
  }
}
