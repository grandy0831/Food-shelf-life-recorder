import 'package:flutter/material.dart';

class Map289Screen extends StatelessWidget {
  const Map289Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seventh Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Seventh Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
