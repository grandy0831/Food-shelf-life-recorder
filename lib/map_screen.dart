import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        backgroundColor: Color(0xFFA3DDEA),
      ),
      body: Center(
        // 在这里放置实际的地图小部件，例如 Google Maps 或其他地图服务
        child: Text("Map content or widget goes here."),
      ),
    );
  }
}
