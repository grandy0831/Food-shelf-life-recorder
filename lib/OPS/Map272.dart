import 'package:flutter/material.dart';

class Map272Screen extends StatelessWidget {
  const Map272Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("First Floor - Map"),
      ),
      body: Center(
        child: Text(
          'First Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
