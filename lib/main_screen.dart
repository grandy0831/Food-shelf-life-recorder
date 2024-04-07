import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'one_pool_street_map_screen.dart'; 
import 'marshgate_map_screen.dart'; 
import 'settings_screen.dart';


class Building {
  final int id;
  final String name;
  final int sensorsAbsent;
  final int sensorsOccupied;

  Building({
    required this.id,
    required this.name,
    required this.sensorsAbsent,
    required this.sensorsOccupied,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      sensorsAbsent: json['sensors_absent'],
      sensorsOccupied: json['sensors_occupied'],
    );
  }
}


Future<List<Building>> fetchBuildings() async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors/summary?token=uclapi-47ccfea341ed403-36900a24718217f-25f091619e58a0a-10c2964300e026b'));

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
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
              // fontFamily: 'YourCustomFont', //字体样式
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 80, 6, 119), 
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.white, 
              onPressed: () {
                // Jump to the Settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
            child: FutureBuilder<List<Building>>(
              future: fetchBuildings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {

                  final List<Building> filteredBuildings = snapshot.data!.where((building) {
                    return building.id == 111 || building.id == 115; 
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredBuildings.length,
                    itemBuilder: (context, index) {
                      final building = filteredBuildings[index];
                      String address = "Address not available"; 
                      return buildCard(
                        context,
                        building.name,
                        address,
                        'Available: ${building.sensorsAbsent}, Occupied: ${building.sensorsOccupied}',
                        "Map for ${building.name}",
                        () {}, 
                      );
                    },
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, String name, String address, String seatAvailability, String mapText, void Function() onTap) {

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

  // 修改 onTap 参数来添加跳转逻辑
  void Function() adjustedOnTap;
  if (adjustedBuildingName == "UCL East - One Pool Street") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OnePoolStreetMapScreen()));
  } else if (adjustedBuildingName == "UCL East - Marshgate") {
    adjustedOnTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MarshgateMapScreen()));
  } else {
    // 如果没有特定的跳转逻辑，可以选择不做任何事，或者弹出提示
    adjustedOnTap = () => print('No map available for this building');
  }


  return Card(
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
          ListTile(
            title: Text(seatAvailability),
          ),
          InkWell(
            onTap: adjustedOnTap, 
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Click here for map', style: TextStyle(fontSize: 16)),
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
  );
}


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}

// 如果MainScreen中用到了其他自定义的小部件或逻辑，也应该将它们移动到这个文件中或适当的文件中
