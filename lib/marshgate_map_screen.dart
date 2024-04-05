import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seatmap/DirectionsScreen2.dart';
import 'package:seatmap/FullScreenMapScreen2.dart';
import 'package:url_launcher/url_launcher.dart';

class MarshgateMapScreen extends StatefulWidget {
  const MarshgateMapScreen({super.key});

  @override
  State<MarshgateMapScreen> createState() => _MarshgateMapScreenState();
}

class _MarshgateMapScreenState extends State<MarshgateMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  bool _isFavorited = false; 

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(51.53771429982378, -0.011622759963721238),
    zoom: 12,
  );

  Future<void> _launchURL() async {
    const url = 'https://www.ucl.ac.uk/ucl-east/ucl-east-0';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _markers.add(
      const Marker(
        markerId: MarkerId("marshgate"),
        position: LatLng(51.53771429982378, -0.011622759963721238),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _goToFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FullScreenMapScreen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Marshgate Map",
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
      body: SingleChildScrollView(
        child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: _goToFullScreenMap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.topLeft, 
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 10.0), 
                    child: Text(
                      "UCL East - Marshgate",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)), 
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 10.0),
                  child: Text(
                    "7 Sidings St, London E20 2AE",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1), 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text("Add to Favourites", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero, 
                        constraints: const BoxConstraints(), 
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorited = !_isFavorited;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1), 
                Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text("View Online Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FullScreenMapScreen2()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1), 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text("Directions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DirectionsScreen2()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1), 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text("About UCL East", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _launchURL,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}