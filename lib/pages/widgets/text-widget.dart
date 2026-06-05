import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key});

  // text widget
  //   @override
  //   Widget build(BuildContext context) {
  //     return Text(
  //       'Hello oun samlanh',
  //       style: TextStyle(
  //         fontSize: 24,
  //         fontWeight: FontWeight.bold,
  //         color:Colors.blue,

  //       ),
  //       textAlign: TextAlign.center,

  //       maxLines: 2,
  //     );
  //   }
  // }

  //container widget
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     width: 200,
  //     height: 200,
  //     padding: const EdgeInsets.all(16),
  //     margin: const EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       color: Colors.orange,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black.withRed(100), blurRadius: 10),
  //       ],
  //     ),
  //    child: const Text('I am a kak developer',
  //    style: TextStyle(fontSize: 25,color:Colors.white),)

  //   );
  // }

  //row widget
  // @override
  // Widget build(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Container(width: 100, height: 100, color: Colors.black12,
  //       padding: EdgeInsets.all(20),
  //       margin: EdgeInsets.all(20),

  //       child: Text('Hello world',style: TextStyle(fontSize: 20,color:Colors.white),
  //       ),
  //       ),
  //       Container(width: 100, height: 100, color: Colors.pink),
  //       Container(width: 100, height: 100, color: Colors.blue),
  //     ],
  //   );
  // }

  // //column widget
  //   @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     // crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Container(width: 100, height: 100, color: Colors.black12,
  //       padding: EdgeInsets.all(20),
  //       margin: EdgeInsets.all(20),

  //       child: Text('Hello world',style: TextStyle(fontSize: 20,color:Colors.white),
  //       ),
  //       ),
  //       Container(width: 100, height: 100, color: Colors.pink),
  //       Container(width: 100, height: 100, color: Colors.blue),
  //     ],
  //   );
  // }

  //column widget
  // @override
  // Widget build(BuildContext context) {
  //   return Stack(
  //     alignment: Alignment.topCenter,
  //     children: [
  //       Container(
  //         width: 200, 
  //         height: 200,
  //         color:Colors.black12,
  //         child: const Text('hello oun',style: TextStyle(
  //           fontSize: 20,
  //           color: Colors.white,backgroundColor: Colors.blue
  //         ),),
          
  //         )],
  //   );
  // }

    @override
  Widget build(BuildContext context) {
    return // As spacer
Column(
  children: [
    Text('Item 1'),
    SizedBox(height: 200),        // vertical space
    Text('Item 2'),
    SizedBox(width: 50, height: 50),  // fixed size box
    Container(color: Colors.cyan, child: Text('Fixed Size')),
  ],
);
  }
}
