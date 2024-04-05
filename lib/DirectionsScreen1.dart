import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsScreen1 extends StatelessWidget {
  const DirectionsScreen1({Key? key}) : super(key: key);

  Future<void> _launchGoogleMap() async {
    const double lat = 51.53840815618917;
    const double lng = -0.009428564204497315;
    final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Directions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 80, 6, 119),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'UCL - East OPS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96)),
              ),
            ),
            const SizedBox(height: 16), // Add some spacing
            const Text(
              'Directions from your current location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchGoogleMap,
                icon: const Icon(Icons.directions, size: 24),
                label: const Text('Google from here', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 80, 6, 119), // 设置按钮颜色为蓝色
                  onPrimary: Colors.white, // 设置文字颜色为白色
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pressing "Google from here" will open Google Maps for driving directions from your current location to UCL East - OPS.',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 16), // Slightly larger text for clarity
              textAlign: TextAlign.center, // Center align the text for consistency
            ),
          ],
        ),
      ),
    );
  }
}
