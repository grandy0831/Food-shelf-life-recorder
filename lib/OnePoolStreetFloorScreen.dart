import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'OPS/Floor272Screen.dart'; 
import 'OPS/Floor273Screen.dart'; 
import 'OPS/Floor274Screen.dart'; 
import 'OPS/Floor277Screen.dart'; 
import 'OPS/Map272.dart'; 
import 'OPS/Map273.dart'; 
import 'OPS/Map274.dart'; 
import 'OPS/Map277.dart'; 


const Map<String, int> floorOrder = {
  'Ground Floor': 0,
  'First Floor': 1,
  'Second Floor': 2,
  'Third Floor': 3,
};

class Floor {
  final int id;
  final String name;
  final int sensorsAbsent;
  final int sensorsOccupied;
  final int sensorsOther;

  Floor({
    required this.id,
    required this.name,
    required this.sensorsAbsent,
    required this.sensorsOccupied,
    required this.sensorsOther,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      name: json['name'],
      sensorsAbsent: json['sensors_absent'],
      sensorsOccupied: json['sensors_occupied'],
      sensorsOther: json['sensors_other'],
    );
  }
}

Future<List<Floor>> fetchOnePoolStreetFloors() async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors/summary?token=uclapi-47ccfea341ed403-36900a24718217f-25f091619e58a0a-10c2964300e026b'));

  if (response.statusCode == 200) {
    List<dynamic> surveysJson = jsonDecode(response.body)['surveys'];
    // Find "East Campus - Pool St"
    var poolStSurvey = surveysJson.firstWhere((survey) => survey['name'] == "East Campus - Pool St", orElse: () => null);
    if (poolStSurvey != null) {
      List<dynamic> floorsJson = poolStSurvey['maps'];
      List<Floor> floors = floorsJson.map((json) => Floor.fromJson(json)).toList();
      floors.sort((a, b) => floorOrder[a.name]!.compareTo(floorOrder[b.name]!));
      return floors;
    } else {
      throw Exception('East Campus - Pool St not found');
    }
  } else {
    throw Exception('Failed to load floors');
  }
}


class OnePoolStreetFloorScreen extends StatefulWidget {
  const OnePoolStreetFloorScreen({super.key});

  @override
  _OnePoolStreetFloorScreenState createState() => _OnePoolStreetFloorScreenState();
}

class _OnePoolStreetFloorScreenState extends State<OnePoolStreetFloorScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  Future<List<Floor>>? _floorsFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFloors();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _loadFloors() {
    _floorsFuture = fetchOnePoolStreetFloors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "One Pool Street Floors",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 48.0,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Trigger UI update
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel),
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
            child: FutureBuilder<List<Floor>>(

            future: fetchOnePoolStreetFloors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                final List<Floor> filteredFloors = snapshot.data!.where((floor) {
                  return floor.id == 277 || floor.id == 273 || floor.id == 274 || floor.id == 272; 
                }).toList();
              
              return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _loadFloors();
                      });
                    },
                    child: ListView.builder(
                      itemCount: filteredFloors.length,
                      itemBuilder: (context, index) {
                      final floor = filteredFloors[index];
                      String address = "Address not available"; 
                        return buildCard(
                          context,
                          floor.name,
                          address,
                          'Available: ${floor.sensorsAbsent}, Occupied: ${floor.sensorsOccupied}, Other: ${floor.sensorsOther}',
                          "Map for ${floor.name}",
                          () {
                            if (floor.name == "First Floor") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor272Screen()));
                            } else if (floor.name == "Second Floor") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const  Floor273Screen()));
                            } else if (floor.name == "Third Floor") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor274Screen()));
                            } else if (floor.name == "Ground Floor") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor277Screen()));
                            }
                          },
                        );
                      },
                    ),
                  );
                }
              },
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

  String adjustedAddress = "One Pool Street, E20 2AF";

  String adjustedBuildingName = name; 
  if (name == "East Campus - Pool St") {
    adjustedBuildingName = "UCL East - One Pool Street"; 
  } else if (name == "East Campus - Marshgate") {
    adjustedBuildingName = "UCL East - Marshgate"; 
  }

  void Function() adjustedOnTap;
  if (name == "First Floor") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => Map272Screen()));
  } else if (name == "Second Floor") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map273Screen()));
  } else if (name == "Third Floor") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map274Screen()));
  } else if (name == "Ground Floor") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map277Screen()));
  } else {
    adjustedOnTap = () => print('No map available for this building');
  }

Map<String, dynamic> getBuildingStatus(String adjustedBuildingName) {
  final now = DateTime.now();
  final weekday = now.weekday;
  final hour = now.hour;

 bool isOpenToday = weekday >= 1 && weekday <= 6;
  bool isOpenNow = (weekday >= 1 && weekday <= 5 && hour >= 8 && hour < 19) || 
                   (weekday == 6 && hour >= 8 && hour < 16);
  String openHours = isOpenToday ? (weekday <= 5 ? "08:00 - 19:00" : "08:00 - 16:00") : "Closed today";

  String statusText = isOpenToday ? (isOpenNow ? "Open now, $openHours" : "Closed now, $openHours") : "Closed today";
    // ignore: unused_local_variable
    Color statusBoxColor = isOpenNow ? Colors.green : Colors.grey;
    // ignore: unused_local_variable
    Color statusTextColor = isOpenNow ? Colors.green : Colors.red;

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
                    child: Text('Show Floor Plan', 
                    style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.map_rounded),
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