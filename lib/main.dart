import 'package:flutter/material.dart';
import 'splash_screen.dart'; 
// ignore: unused_import
import 'main_screen.dart'; 
import 'favorites_model.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesModel(),
      child: MaterialApp(
        title: 'SeatMap',
        home: SplashScreen(), 
      ),
    );
  }
}