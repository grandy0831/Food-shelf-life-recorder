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

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomId: json['room_id'] ?? 'Unknown ID',
        roomType: json['description_2'] ?? 'Unknown Type',
      );

  void addSeat(bool occupied) {
    totalSeats++;
    if (occupied) occupiedSeats++;
  }
}

// 用于处理多个楼层的函数
Future<Map<String, List<Room>>> fetchRoomsForFloors(List<String> floorNames) async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors?survey_id=115&token=${Secrets.UCLApiKey}'));
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
      String roomType = sensor['description_2'] ?? 'Unknown Type';
      if (roomType == 'Unknown Type') continue;

      rooms.putIfAbsent(roomType, () => Room.fromJson(sensor)).addSeat(sensor['occupied'] ?? false);
    }

    floorRooms[floorName] = rooms.values.toList();
  }

  return floorRooms;
}

class Map283Screen extends StatefulWidget {
  @override
  _Map283ScreenState createState() => _Map283ScreenState();
}

class _Map283ScreenState extends State<Map283Screen> {
  Map<String, List<Room>>? _floorRooms;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final floorRooms = await fetchRoomsForFloors(["Floor 1", "Floor 2", "Floor 3"]);
      setState(() {
        _floorRooms = floorRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Failed to load rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map of 3F - Marshgate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRooms)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _floorRooms?.keys.length ?? 0,
              itemBuilder: (context, index) {
                String floor = _floorRooms!.keys.elementAt(index);
                return ExpansionTile(
                  title: Text(floor),
                  children: _floorRooms![floor]!.map<Widget>((room) => buildRoomCard(room, floor)).toList(),
                );
              },
            ),
    );
  }

  Widget buildRoomCard(Room room, String floor) {
    Color availabilityColor = getAvailabilityColor(room);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      child: ListTile(
        title: Text('${room.roomType}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Floor: $floor', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 25,
                  decoration: BoxDecoration(color: availabilityColor, borderRadius: BorderRadius.circular(6.0)),
                  alignment: Alignment.center,
                  child: const Text("Seats", style: TextStyle(color:
    Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
    Expanded(
    child: Text(" ${room.totalSeats - room.occupiedSeats} available / ${room.totalSeats} total", style: const TextStyle(fontSize: 16))
    ),
    ],
    ),
    ],
    ),
    ),
    );
    }

Color getAvailabilityColor(Room room) {
double availablePercentage = (room.totalSeats - room.occupiedSeats) / room.totalSeats;
if (availablePercentage > 0.5) return Colors.green;
if (availablePercentage >= 0.2) return Colors.amber;
return Colors.red;
}
}


