import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Marshgate/Floor282Screen.dart'; 
import 'Marshgate/Floor283Screen.dart'; 
import 'Marshgate/Floor285Screen.dart'; 
import 'Marshgate/Floor286Screen.dart'; 
import 'Marshgate/Floor287Screen.dart'; 
import 'Marshgate/Floor288Screen.dart'; 
import 'Marshgate/Floor289Screen.dart'; 
import 'Marshgate/Floor294Screen.dart'; 
import 'Marshgate/Map282.dart'; 
import 'Marshgate/Map283.dart'; 
import 'Marshgate/Map285.dart'; 
import 'Marshgate/Map286.dart'; 
import 'Marshgate/Map287.dart'; 
import 'Marshgate/Map288.dart'; 
import 'Marshgate/Map289.dart'; 
import 'Marshgate/Map294.dart'; 


const Map<String, int> floorOrder = {
  'Floor 1': 0,
  'Second Floor': 1,
  'Floor 2': 2,
  'Floor 3': 3,
  'Floor 4': 4,
  'Fifth Floor': 5,
  'Floor 6': 6,
  'Floor 7': 7,
  'Floor 8': 8,
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

Future<List<Floor>> fetchMarshgateFloors() async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors/summary?token=uclapi-47ccfea341ed403-36900a24718217f-25f091619e58a0a-10c2964300e026b'));

  if (response.statusCode == 200) {
    List<dynamic> surveysJson = jsonDecode(response.body)['surveys'];
    // Find "East Campus - Marshgate"
    var poolStSurvey = surveysJson.firstWhere((survey) => survey['name'] == "East Campus - Marshgate", orElse: () => null);
    if (poolStSurvey != null) {
      List<dynamic> floorsJson = poolStSurvey['maps'];
      List<Floor> floors = floorsJson.map((json) => Floor.fromJson(json)).toList();
      floors.sort((a, b) => floorOrder[a.name]!.compareTo(floorOrder[b.name]!));
      return floors;
    } else {
      throw Exception('East Campus - Marshgate not found');
    }
  } else {
    throw Exception('Failed to load floors');
  }
}

class MarshgateFloorScreen extends StatefulWidget {
  const MarshgateFloorScreen({super.key});

  @override
  _MarshgateFloorScreenState createState() => _MarshgateFloorScreenState();
}

class _MarshgateFloorScreenState extends State<MarshgateFloorScreen> {
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
    _floorsFuture = fetchMarshgateFloors();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Marshgate Floors",
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

            future: fetchMarshgateFloors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                final List<Floor> filteredFloors = snapshot.data!.where((floor) {
                  return floor.id == 282 || floor.id == 294 || floor.id == 283 || floor.id == 286 || floor.id == 285 || floor.id == 288 || floor.id == 289 || floor.id == 287 ; 
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
                            if (floor.name == "Floor 1") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor282Screen()));
                            } else if (floor.name == "Floor 2") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const  Floor294Screen()));
                            } else if (floor.name == "Floor 3") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor283Screen()));
                            } else if (floor.name == "Floor 4") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor286Screen()));
                            } else if (floor.name == "Fifth Floor") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor285Screen()));
                            } else if (floor.name == "Floor 6") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor288Screen()));
                            } else if (floor.name == "Floor 7") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor289Screen()));
                            } else if (floor.name == "Floor 8") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Floor287Screen()));
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

  String adjustedAddress = "Marshgate, E20 2AE";

  String adjustedBuildingName = name; 
  if (name == "Floor 1") {
    adjustedBuildingName = "First Floor"; 
  } else if (name == "Floor 2") {
    adjustedBuildingName = "Second Floor"; 
  } else if (name == "Floor 3") {
    adjustedBuildingName = "Third Floor"; 
  } else if (name == "Floor 4") {
    adjustedBuildingName = "Fourth Floor"; 
  } else if (name == "Fifth Floor") {
    adjustedBuildingName = "Fifth Floor"; 
  } else if (name == "Floor 6") {
    adjustedBuildingName = "Sixth Floor"; 
  } else if (name == "Floor 7") {
    adjustedBuildingName = "Seventh Floor"; 
  } else if (name == "Floor 8") {
    adjustedBuildingName = "Eighth Floor"; 
  }

  void Function() adjustedOnTap;
  if (name == "Floor 1") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map282Screen()));
  } else if (name == "Floor 2") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map294Screen()));
  } else if (name == "Floor 3") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map283Screen()));
  } else if (name == "Floor 4") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map286Screen()));
  } else if (name == "Fifth Floor") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map285Screen()));
  } else if (name == "Floor 6") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map288Screen()));
  } else if (name == "Floor 7") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map289Screen()));
  } else if (name == "Floor 8") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Map287Screen()));

  } else {
    adjustedOnTap = () => print('No map available for this building');
  }

Map<String, dynamic> getBuildingStatus(String adjustedBuildingName) {
  final now = DateTime.now();
  // final weekday = now.weekday;
  final hour = now.hour;

  bool isOpenToday = true;
  bool isOpenNow = hour >= 7 && hour < 21;
  String openHours = "07:00 - 21:00";

  String statusText = isOpenNow ? "Open now, $openHours" : "Closed now, $openHours";
  // Color statusBoxColor = isOpenNow ? Colors.green : Colors.grey;
  // Color statusTextColor = isOpenNow ? Colors.green : Colors.red;

  // statusText = isOpenToday ? (isOpenNow ? "Open now, $openHours" : "Closed now, $openHours") : "Closed today";

  return {
    'isOpenNow': isOpenNow,
    'isOpenToday': isOpenToday,
    'statusText': statusText,
    'statusBoxColor': isOpenNow ? Colors.green : Colors.grey, 
    'statusTextColor': isOpenNow ? Colors.green : Colors.red 
  };
}

Map<String, dynamic> status = getBuildingStatus(adjustedBuildingName);
// bool isOpenNow = status['isOpenNow'];
// bool isOpenToday = status['isOpenToday'];
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