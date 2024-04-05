import 'package:flutter/material.dart';
import 'splash_screen.dart'; 
// ignore: unused_import
import 'main_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SeatMap',
      home: SplashScreen(), 
    );
  }
}
