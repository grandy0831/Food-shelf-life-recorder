import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMapScreen1 extends StatefulWidget {
  const FullScreenMapScreen1({super.key});

  @override
  _FullScreenMapScreenState createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen1> {
  final Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(51.53840815618917, -0.009428564204497315), 
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();

    _markers.add(
      const Marker(
        markerId: MarkerId('marshgate'), 
        position: LatLng(51.53840815618917, -0.009428564204497315), 
        infoWindow: InfoWindow(
          title: 'UCL East - OPS', 
          snippet: '1 Pool St, London E20 2AF', 
        ),
        icon: BitmapDescriptor.defaultMarker, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OPS Map",
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
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        markers: _markers, 
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
