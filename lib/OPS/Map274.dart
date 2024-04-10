import 'package:flutter/material.dart';

class Map274Screen extends StatelessWidget {
  const Map274Screen({Key? key}) : super(key: key);

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
