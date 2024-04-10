import 'package:flutter/material.dart';

class Map288Screen extends StatelessWidget {
  const Map288Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sixth Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Sixth Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
