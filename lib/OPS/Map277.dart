import 'package:flutter/material.dart';

class Map277Screen extends StatelessWidget {
  const Map277Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ground Floor - Map"),
      ),
      body: Center(
        child: Text(
          'Ground Floor Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
