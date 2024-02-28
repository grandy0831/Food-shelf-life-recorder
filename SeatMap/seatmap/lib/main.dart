import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA3DDEA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // show icon
            Image.asset('assets/images/icon.jpg', width: 250, height: 250),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Add listener
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  // Check for text changes
  void _onSearchChanged() {
    // UpdateUI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SeatMap',
          style: TextStyle(
            fontSize: 24.0, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
            // fontFamily: 'YourCustomFont', //字体样式
          ),
        ),
        backgroundColor: Color(0xFFA3DDEA), 
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white, 
            onPressed: () {
              // Jump to the Settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 48.0,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Update UI
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                buildCard(context, 'UCL East - One Pool Street', '1 Pool St, London E20 2AF', 'Seat availability here...', 'Map for OPS'),
                SizedBox(height: 8),
                buildCard(context, 'UCL East - Marshgate', '7 Sidings St, London E20 2AE', 'Seat availability here...', 'Map for Marshgate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, String buildingName, String address, String seatAvailability, String mapText) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(buildingName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(address),
            trailing: IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Navigate to building details page
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text(seatAvailability),
            // TODO: Show actual seat availability from API
          ),
          ListTile(
            title: Text('Click here for map'),
            trailing: Icon(Icons.location_on ),
            onTap: () {
              // TODO: Navigate to map screen
            },
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Text("Settings Page"),
      ),
    );
  }
}
