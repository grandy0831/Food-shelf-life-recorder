import 'package:flutter/material.dart';

class Map273Screen extends StatelessWidget {
  const Map273Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Second Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
