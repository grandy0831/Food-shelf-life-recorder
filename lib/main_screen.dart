import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:seatmap/api_secrets.dart';
import 'package:seatmap/study.dart';
import 'package:seatmap/study_space.dart';
import 'dart:convert';

import 'My_favourites.dart';
import 'one_pool_street_map_screen.dart'; 
import 'marshgate_map_screen.dart'; 
import 'settings_screen.dart';
import 'MarshgateFloorScreen.dart';
import 'OnePoolStreetFloorScreen.dart';

class Building {
  final int id;
  final String name;
  final int sensorsAbsent;
  final int sensorsOccupied;
  final int sensorsOther;

  Building({
    required this.id,
    required this.name,
    required this.sensorsAbsent,
    required this.sensorsOccupied,
    required this.sensorsOther,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      sensorsAbsent: json['sensors_absent'],
      sensorsOccupied: json['sensors_occupied'],
      sensorsOther: json['sensors_other'],
    );
  }
}


Future<List<Building>> fetchBuildings() async {
  String apiKey = Secrets.UCLApiKey;
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors/summary?token=$apiKey'));

  if (response.statusCode == 200) {
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);
    List<dynamic> surveysData = decodedResponse['surveys'];
    List<Building> buildings = surveysData.map((data) => Building.fromJson(data)).toList();
    return buildings;
  } else {
    throw Exception('Failed to load buildings');
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  Future<List<Building>>? _buildingsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadBuildings();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _loadBuildings() {
    _buildingsFuture = fetchBuildings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SeatMap',
          style: TextStyle(
            fontSize: 24.0, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 57, 119, 173), 
        leading: IconButton( 
          icon: const Icon(Icons.settings),
          color: Colors.white, 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.white, 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyFavoritesScreen()),  
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Building>>(
        future: fetchBuildings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            final List<Building> filteredBuildings = snapshot.data!.where((building) {
              return building.id == 111 || building.id == 115; 
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadBuildings();
                });
              },
              child: ListView.builder(
                itemCount: filteredBuildings.length,
                itemBuilder: (context, index) {
                  final building = filteredBuildings[index];
                  String address = "Address not available"; 
                  return buildCard(
                    context,
                    building.name,
                    address,
                    'Available: ${building.sensorsAbsent}, Occupied: ${building.sensorsOccupied}, Other: ${building.sensorsOther}',
                    "Map for ${building.name}",
                    () {
                      if (building.name == "East Campus - Pool St") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OnePoolStreetFloorScreen()));
                      } else if (building.name == "East Campus - Marshgate") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MarshgateFloorScreen()));
                      }  
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,  
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 240, 
            height: 45, 
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
              icon: const Icon(Icons.search, color: Colors.white), 
              label: const Text('Search All Rooms',
                style: TextStyle(
                  fontSize: 16.0, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                ),
              ),  
              backgroundColor: Color.fromARGB(162, 137, 200, 255),  
              elevation: 4.0,  
            ),
          ),
          const SizedBox(height: 16), 
          SizedBox(
            width: 240, 
            height: 45, 
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudySpaceSearchScreen()),  
                );
              },
              icon: const Icon(Icons.search, color: Colors.white), 
              label: const Text('Search Study Spaces',
                style: TextStyle(
                  fontSize: 16.0, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white, 
                ),
              ),  
              backgroundColor: const Color.fromARGB(163, 57, 119, 173),  
              elevation: 4.0,  
            ),
          ),
        ],
      ),
    );
  }


  Widget buildCard(
    BuildContext context,
    String name, 
    String address, 
    String seatAvailability, 
    String mapText, 
    void Function() onTap) {

    // Analyze seating conditions
  final parts = seatAvailability.split(', ');
  final available = int.parse(parts[0].split(': ')[1]);
  final occupied = int.parse(parts[1].split(': ')[1]);
  final other = int.parse(parts[2].split(': ')[1]);
  final total = available + occupied + other;
  final double availablePercentage = available / total;

  Color availabilityColor;
  if (availablePercentage > 0.5) {
    availabilityColor = Colors.green; 
  } else if (availablePercentage >= 0.2) {
    availabilityColor = Color.fromARGB(255, 255, 200, 0); 
  } else {
    availabilityColor = Colors.red; 
  }

  String adjustedAddress = address; 
  if (name == "East Campus - Pool St") {
    adjustedAddress = "1 Pool St, London E20 2AF"; 
  } else if (name == "East Campus - Marshgate") {
    adjustedAddress = "7 Sidings St, London E20 2AE"; 
  }

  String adjustedBuildingName = name; 
  if (name == "East Campus - Pool St") {
    adjustedBuildingName = "UCL East - One Pool Street"; 
  } else if (name == "East Campus - Marshgate") {
    adjustedBuildingName = "UCL East - Marshgate"; 
  }

  void Function() adjustedOnTap;
  if (adjustedBuildingName == "UCL East - One Pool Street") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OnePoolStreetMapScreen()));
  } else if (adjustedBuildingName == "UCL East - Marshgate") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MarshgateMapScreen()));
  } else {
    adjustedOnTap = () => print('No map available for this building');
  }


Map<String, dynamic> getBuildingStatus(String adjustedBuildingName) {
  final now = DateTime.now();
  final weekday = now.weekday;
  final hour = now.hour;

  bool isOpenToday;
  bool isOpenNow;
  String openHours;
  String statusText;

  // Based on the name of the building and the current time, determine whether it is open today and whether it is currently open
  switch (adjustedBuildingName) {
    case "UCL East - One Pool Street":
      isOpenToday = weekday >= 1 && weekday <= 6; 
      isOpenNow = (weekday >= 1 && weekday <= 5 && hour >= 8 && hour < 19) || (weekday == 6 && hour >= 8 && hour < 16);
      openHours = weekday >= 1 && weekday <= 5 ? "08:00 - 19:00" : weekday == 6 ? "08:00 - 16:00" : "Closed";
      break;
    case "UCL East - Marshgate":
      isOpenToday = true; 
      isOpenNow = hour >= 7 && hour < 21;
      openHours = "07:00 - 21:00";
      break;
    default:
      isOpenToday = isOpenNow = false;
      openHours = "Closed";
      break;
  }

  statusText = isOpenToday ? (isOpenNow ? "Open now, $openHours" : "Closed now, $openHours") : "Closed today";

  return {
    'isOpenNow': isOpenNow,
    'isOpenToday': isOpenToday,
    'statusText': statusText,
    'statusBoxColor': isOpenNow ? Colors.green : Colors.grey, 
    'statusTextColor': isOpenNow ? Colors.green : Colors.red 
  };
}

Map<String, dynamic> status = getBuildingStatus(adjustedBuildingName);
// ignore: unused_local_variable
bool isOpenNow = status['isOpenNow'];
// ignore: unused_local_variable
bool isOpenToday = status['isOpenToday'];
String statusText = status['statusText'];
Color statusBoxColor = status['statusBoxColor'];
Color statusTextColor = status['statusTextColor'];


  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0), 
    child: Card(
      elevation: 2,  
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)  
      ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        adjustedBuildingName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        adjustedAddress, 
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onTap, 
              ),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), 
            decoration: BoxDecoration(
              color: availabilityColor,
              borderRadius: BorderRadius.circular(8), 
            ),
                  child: const Text(
                    'Seats',
                    style: TextStyle(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                    ), 
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$available available / $total total',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
                  decoration: BoxDecoration(
                    color: statusBoxColor, 
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: const Text(
                    'Status',
                    style: TextStyle(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                    ), 
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: statusTextColor),
                ),
              ],
            ),
          ),

          const Divider(),
          InkWell(
            onTap: adjustedOnTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Click here for map', 
                    style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.location_on),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
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