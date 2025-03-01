import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsScreen2 extends StatelessWidget {
  const DirectionsScreen2({Key? key}) : super(key: key);

  Future<void> _launchGoogleMap() async {
    const double lat = 51.53771429982378;
    const double lng = -0.011622759963721238;
    const String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";

    // ignore: deprecated_member_use
    if (await canLaunch(googleMapsUrl)) {
      // ignore: deprecated_member_use
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
        backgroundColor: const Color.fromARGB(255, 57, 119, 173),
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
                'UCL - East Marshgate',
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
                  foregroundColor: Colors.white, backgroundColor:const Color.fromARGB(219, 57, 78, 173), 
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pressing "Google from here" will open Google Maps for driving directions from your current location to UCL East - Marshgate.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16), 
              textAlign: TextAlign.center, 
            ),
          ],
        ),
      ),
    );
  }
}
