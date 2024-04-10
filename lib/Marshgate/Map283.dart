import 'package:flutter/material.dart';

class Map283Screen extends StatelessWidget {
  const Map283Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Third Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Third Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
