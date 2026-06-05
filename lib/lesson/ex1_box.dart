// import 'package:flutter/material.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       backgroundColor: Colors.blue,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
        
//         Text(
//           'Header',
//           style: TextStyle(color:Colors.white),
//         ),

//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(
//             'Menu',
//             style: TextStyle(color:Colors.white),
//           ),
//         ),
//         ActionChip(
//           label: Text('Action'),
//           onPressed: () {
//             // Action when the chip is pressed
//           },
//         ),
//       ],

//       ),
        
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Header',
              style: TextStyle(color:Colors.white),
            ),
            Text(
              'Menu',
              style: TextStyle(color:Colors.white,fontSize: 25),
              
            ),
           ActionChip(
            label: Text('Action'),
            onPressed:(){
              Icon(Icons.add);
            },
           )

          ],
        ),
      ),
    
    );
  }
}