import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seatmap/api_secrets.dart';

class Room {
  final String roomId;
  final String roomType;
  int totalSeats = 0;
  int occupiedSeats = 0;

  Room({required this.roomId, required this.roomType});

  factory Room.fromJson(Map<String, dynamic> json, String roomNameKey) => Room(
        roomId: json['room_id'] ?? 'Unknown ID',
        roomType: json[roomNameKey] ?? 'Unknown Type',
      );

  void addSeat(bool occupied) {
    totalSeats++;
    if (occupied) occupiedSeats++;
  }
}

Future<Map<String, List<Room>>> fetchRoomsForFloors(List<String> floorNames, String surveyId, String roomNameKey) async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors?survey_id=$surveyId&token=${Secrets.UCLApiKey}'));
  if (response.statusCode != 200) throw Exception('Failed to load room data');
  
  var data = jsonDecode(response.body);
  Map<String, List<Room>> floorRooms = {};
  
  for (var floorName in floorNames) {
    var floorMap = data['maps'].firstWhere((map) => map['name'] == floorName, orElse: () => null);
    if (floorMap == null) {
      floorRooms[floorName] = [];
      continue;
    }
  
    List<dynamic> sensors = floorMap['sensors'].values.toList();
    Map<String, Room> rooms = {};
    for (var sensor in sensors) {
      String roomType = sensor[roomNameKey] ?? 'Unknown Type';
      if (roomType == 'Unknown Type') continue;

      rooms.putIfAbsent(roomType, () => Room.fromJson(sensor, roomNameKey)).addSeat(sensor['occupied'] ?? false);
    }

    floorRooms[floorName] = rooms.values.toList();
  }

  return floorRooms;
}

class StudySpaceSearchScreen extends StatefulWidget {
  @override
  _StudySpaceSearchScreenState createState() => _StudySpaceSearchScreenState();
}

class _StudySpaceSearchScreenState extends State<StudySpaceSearchScreen> {
  Map<String, List<Room>>? _floorRoomsBuilding1;
  Map<String, List<Room>>? _floorRoomsBuilding2;
  bool _isLoadingBuilding1 = true;
  bool _isLoadingBuilding2 = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final floorRoomsBuilding1 = await fetchRoomsForFloors(["Floor 1", "Floor 2", "Floor 3", "Floor 4", "Floor 5", "Floor 6", "Floor 7", "Floor 8"], "115", "description_2");
      final floorRoomsBuilding2 = await fetchRoomsForFloors(["Ground Floor", "First Floor", "Second Floor", "Third Floor"], "111", "description_1");
      setState(() {
        _floorRoomsBuilding1 = floorRoomsBuilding1;
        _floorRoomsBuilding2 = floorRoomsBuilding2;
        _isLoadingBuilding1 = false;
        _isLoadingBuilding2 = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBuilding1 = false;
        _isLoadingBuilding2 = false;
      });
      print('Failed to load rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Spaces",
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
      body: _isLoadingBuilding1 || _isLoadingBuilding2
          ? const Center(child: CircularProgressIndicator())
          : _buildMapWidget(),
    );
  }

Widget _buildMapWidget() {
  return SingleChildScrollView(
    child: Column(
      children: [
        if (_floorRoomsBuilding1 != null) ..._buildFilteredRoomsList(_floorRoomsBuilding1!),
        if (_floorRoomsBuilding2 != null) ..._buildFilteredRoomsList(_floorRoomsBuilding2!),
      ],
    ),
  );
}

List<Widget> _buildFilteredRoomsList(Map<String, List<Room>> floorRooms) {
  List<Widget> roomCards = [];
  for (var floor in floorRooms.keys) {
    roomCards.addAll(
      floorRooms[floor]!
          .where((room) =>
              room.roomType.toLowerCase().contains('study space') ||
              room.roomType.toLowerCase().contains('library') ||
              room.roomType.toLowerCase().contains('learning hub'))
          .map<Widget>((room) => _buildRoomCard(room, floor))
          .toList(),
    );
  }
  return roomCards;
}


Widget _buildRoomCard(Room room, String floor) {
  String formattedFloor = _formatFloor(floor);
  Color availabilityColor = _getAvailabilityColor(room);
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), 
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), 
      title: Text('${room.roomType}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4), 
          Text('$formattedFloor', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 4), 
          Row(
            children: [
              Container(
                width: 60,
                height: 25,
                decoration: BoxDecoration(color: availabilityColor, borderRadius: BorderRadius.circular(6.0)),
                alignment: Alignment.center,
                child: const Text("Seats", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                child: Text(" ${room.totalSeats - room.occupiedSeats} available / ${room.totalSeats} total", style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  String _formatFloor(String floor) {
    if (floor.startsWith("Floor")) {
      int floorNumber = int.tryParse(floor.split(" ")[1]) ?? 0;
      return "${floorNumber}F - Marshgate";
    } else if (floor == "Ground Floor") {
      return "GF - OPS";
    } else if (floor == "First Floor") {
      return "1F - OPS";
    } else if (floor == "Second Floor") {
      return "2F - OPS";
    } else if (floor == "Third Floor") {
      return "3F - OPS";
    } else {
      return floor;
    }
  }

Color _getAvailabilityColor(Room room) {
  double availablePercentage = (room.totalSeats - room.occupiedSeats) / room.totalSeats;
  if (availablePercentage > 0.5) return Colors.green;
  if (availablePercentage >= 0.2) return Colors.amber;
  return Colors.red;
}
}
