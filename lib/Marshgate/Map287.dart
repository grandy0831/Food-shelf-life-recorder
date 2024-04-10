import 'package:flutter/material.dart';

class Map287Screen extends StatelessWidget {
  const Map287Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eighth Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Eighth Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
