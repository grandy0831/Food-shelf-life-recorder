import 'package:flutter/material.dart';

class Map285Screen extends StatelessWidget {
  const Map285Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fifth Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Fifth Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
