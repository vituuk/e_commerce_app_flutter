import 'package:flutter/material.dart';

class  RegistrationFormScreen extends StatelessWidget {
  const RegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {

     final _formKey = GlobalKey<FormState>();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Form Widget")),
        body: Padding(  
          padding: const EdgeInsets.all(20),
          child: Form( 
            key: _formKey,
            child: Column(
              children: [
                const Text( "This is form"),
                ElevatedButton(onPressed: (){}, child: const Text('VITU'))
              ],
            ),
          ),
        )
      ),
    );
  }
}