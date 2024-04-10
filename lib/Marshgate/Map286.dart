import 'package:flutter/material.dart';

class Map286Screen extends StatelessWidget {
  const Map286Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fourth Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Fourth Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
