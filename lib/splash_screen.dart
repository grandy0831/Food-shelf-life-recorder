import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart'; 

import 'main_screen.dart'; 
import 'error_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = false; 

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Timer(const Duration(seconds: 2), () {
      if (_isConnected) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ErrorScreen()));
      }
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isConnected = true; 
      });
    } else {
      setState(() {
        _isConnected = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA3DDEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/icon.png', width: 350, height: 350),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
