import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        backgroundColor: const Color.fromARGB(255, 80, 6, 119),
      ),
      body: const Center(
        // 在这里放置实际的地图小部件，例如 Google Maps 或其他地图服务
        child: Text("Map content or widget goes here."),
      ),
    );
  }
}
