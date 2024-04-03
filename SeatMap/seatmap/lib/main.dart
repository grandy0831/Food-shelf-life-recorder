import 'package:flutter/material.dart';
import 'splash_screen.dart'; 
// ignore: unused_import
import 'main_screen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeatMap',
      home: SplashScreen(), 
    );
  }
}
