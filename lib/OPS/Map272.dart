import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seatmap/api_secrets.dart';

const Map<String, int> room = {
  'Connected Environments': 0,
  'Student Study Space': 1,
  'Student Learning Hub ': 2,
  'Digital Accessibility Hub Students': 3,
  'Digital Accessibility Hub Staff': 4,
  'People and Nature': 5,
};



class Room {
  final String roomId;
  final String roomType;
  int totalSeats;
  int occupiedSeats;
  bool isHighlighted;

  Room({
    required this.roomId,
    required this.roomType,
    this.totalSeats = 0,
    this.occupiedSeats = 0,
    this.isHighlighted = false,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'] ?? '',
      roomType: json['description_1'] ?? 'Unknown Type',
      totalSeats: 0,
      occupiedSeats: 0,
    );
  }

  void addSeat(bool occupied) {
    totalSeats += 1;
    if (occupied) {
      occupiedSeats += 1;
    }
  }

  Rect getArea(Map<String, Rect> areas) => areas[roomType] ?? Rect.zero;
}


Future<List<Room>> fetchRoomsForFloor(String floorName) async {
  String apiKey = Secrets.UCLApiKey;
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors?survey_id=111&token=$apiKey'));
  
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var floorMap = data['maps'].firstWhere((map) => map['name'] == floorName, orElse: () => null);
    if (floorMap == null) {
      throw Exception('Floor $floorName not found');
    }
    List<dynamic> sensors = floorMap['sensors'].values.toList();
    Map<String, Room> rooms = {};

    for (var sensor in sensors) {
      String roomType = sensor['description_1'] ?? 'Unknown Type';
      if (roomType == 'Unknown Type') continue;
      bool occupied = sensor['occupied'] ?? false;

      rooms.putIfAbsent(roomType, () => Room.fromJson({
        'room_id': sensor['room_id'] ?? 'Unknown ID',
        'description_1': roomType,
      })).addSeat(occupied);
    }

    var roomsList = rooms.values.toList();
    roomsList.sort((a, b) {
      int indexA = room[a.roomType] ?? roomsList.length;
      int indexB = room[b.roomType] ?? roomsList.length;
      return indexA.compareTo(indexB);
    });
    return roomsList;
  } else {
    throw Exception('Failed to load room data');
  }
}

class MAP272Screen extends StatefulWidget {
  const MAP272Screen({super.key});

  @override
  _MAP272ScreenState createState() => _MAP272ScreenState();
}

class _MAP272ScreenState extends State<MAP272Screen> {
  List<Room>? _rooms;
  bool _isLoading = true;
  Room? _highlightedRoom;
  final TransformationController _controller = TransformationController();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rooms = await fetchRoomsForFloor("First Floor");
      setState(() {
        _rooms = rooms;
        _highlightedRoom = null;  
      });
    } catch (e) {
      print('Failed to load rooms: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _reloadPage() {
    _controller.value = Matrix4.identity();  
    _fetchRooms();
  }



  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Map<String, Rect> workspaceAreas = {
      'Connected Environments': Rect.fromLTWH(screenSize.width * 0.275, screenSize.height * 0.2455, screenSize.width * 0.022, screenSize.height * 0.01),
      'Student Study Space': Rect.fromLTWH(screenSize.width * 0.275, screenSize.height * 0.13, screenSize.width * 0.022, screenSize.height * 0.01),
      'Student Learning Hub ': Rect.fromLTWH(screenSize.width * 0.365, screenSize.height * 0.105, screenSize.width * 0.022, screenSize.height * 0.01),
      'Digital Accessibility Hub Students': Rect.fromLTWH(screenSize.width * 0.485, screenSize.height * 0.076, screenSize.width * 0.022, screenSize.height * 0.01),
      'Digital Accessibility Hub Staff': Rect.fromLTWH(screenSize.width * 0.488, screenSize.height * 0.095, screenSize.width * 0.022, screenSize.height * 0.01),
      'People and Nature': Rect.fromLTWH(screenSize.width * 0.74, screenSize.height * 0.06, screenSize.width * 0.022, screenSize.height * 0.01),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "1F - One Pool Street",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 57, 119, 173),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPage,
          ),
        ],
      ),
body: Column(
        children: [
          Expanded(
            flex: 4,
            child: InteractiveViewer(
              transformationController: _controller,
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.1,
              maxScale: 4.0,
              child: Stack(
                children: [
                  Image.asset('assets/images/01-one-pool-street.png', fit: BoxFit.cover),
                  if (_highlightedRoom != null)
                    Positioned.fromRect(
                      rect: workspaceAreas[_highlightedRoom!.roomType]!,
                      child: Container(
                        color: const Color.fromARGB(162, 244, 69, 69).withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          alignment: Alignment.center,
          color: Colors.grey[200],  
          child: const Text(
            "Tap a card to highlight a room",
            style: TextStyle(color: Color.fromARGB(255, 58, 58, 58), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
          Expanded(
            flex: 6,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _rooms?.length ?? 0,
                    itemBuilder: (context, index) {
                      final room = _rooms![index];
                      return buildRoomCard(room);
                    },
                  ),
          ),
        ],
      ),
    );
  }

Widget buildRoomCard(Room room) {
  Color availabilityColor = getAvailabilityColor(room);
  double borderRadiusValue = 6.0;  

  return Card(
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusValue),  
    ),
    child: ListTile(
      title: Text(
        room.roomType,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 25,
              decoration: BoxDecoration(
                color: availabilityColor,
                borderRadius: BorderRadius.circular(borderRadiusValue),  
              ),
              alignment: Alignment.center,
              child: const Text(
                "Seats",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                "  ${room.totalSeats - room.occupiedSeats} available / ${room.totalSeats} total",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _highlightedRoom = _highlightedRoom == room ? null : room;
        });
      },
      selected: _highlightedRoom == room,
      selectedTileColor: Colors.blue[100],  
    ),
  );
}

  Color getAvailabilityColor(Room room) {
    final double availablePercentage = (room.totalSeats - room.occupiedSeats) / room.totalSeats;
    if (availablePercentage > 0.5) {
      return Colors.green;
    } else if (availablePercentage >= 0.2) {
      return const Color.fromARGB(255, 255, 200, 0);
    } else {
      return Colors.red;
    }
  }
}