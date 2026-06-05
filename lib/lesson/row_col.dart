import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Row and Column', style: TextStyle(color:Colors.red,backgroundColor: Colors.blue),),
      ),
      body: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            color:Colors.yellow,
            child: const Text("column1"),
            
          ),
            Container(
            width: 200,
            height: 200,
            color:Colors.purple,
            child: const Text("column1"),
            
          ) , Container(
            width: 200,
            height: 200,
            color:Colors.red,
            child: const Text("column1"),
            
          ),  Container(
            width: 200,
            height: 200,
            color:Colors.green,
            child: const Text("column1"),
            
          )
        ],
      ),
    );
  }
}