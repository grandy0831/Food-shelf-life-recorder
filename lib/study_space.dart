import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:seatmap/api_secrets.dart';
import 'favorites_model.dart';

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

Future<Map<String, List<Room>>> fetchRoomsForFloors(
    List<String> floorNames, String surveyId, String roomNameKey) async {
  final response = await http.get(Uri.parse(
      'https://uclapi.com/workspaces/sensors?survey_id=$surveyId&token=${Secrets.UCLApiKey}'));
  if (response.statusCode != 200) throw Exception('Failed to load room data');

  var data = jsonDecode(response.body);
  Map<String, List<Room>> floorRooms = {};

  for (var floorName in floorNames) {
    var floorMap =
        data['maps'].firstWhere((map) => map['name'] == floorName, orElse: () => null);
    if (floorMap == null) {
      floorRooms[floorName] = [];
      continue;
    }

    List<dynamic> sensors = floorMap['sensors'].values.toList();
    Map<String, Room> rooms = {};
    for (var sensor in sensors) {
      String roomType = sensor[roomNameKey] ?? 'Unknown Type';
      if (roomType == 'Unknown Type') continue;

      rooms.putIfAbsent(
          roomType, () => Room.fromJson(sensor, roomNameKey)).addSeat(sensor['occupied'] ?? false);
    }

    floorRooms[floorName] = rooms.values.toList();
  }

  return floorRooms;
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, List<Room>>? _floorRoomsBuilding1;
  Map<String, List<Room>>? _floorRoomsBuilding2;
  bool _isLoadingBuilding1 = true;
  bool _isLoadingBuilding2 = true;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRooms() async {
    try {
      final floorRoomsBuilding1 = await fetchRoomsForFloors([
        "Floor 1",
        "Floor 2",
        "Floor 3",
        "Floor 4",
        "Floor 5",
        "Floor 6",
        "Floor 7",
        "Floor 8"
      ], "115", "description_2");
      final floorRoomsBuilding2 = await fetchRoomsForFloors(
          ["Ground Floor", "First Floor", "Second Floor", "Third Floor"], "111", "description_1");
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

  Future<void> _refreshRooms() async {
    await _fetchRooms();
  }

  void _searchRooms(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search",
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 48.0,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchRooms,
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
                                  _searchRooms('');
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
                  child: RefreshIndicator(
                    onRefresh: _refreshRooms,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_floorRoomsBuilding1 != null || _floorRoomsBuilding2 != null)
                            ..._buildRoomsList(
                                _floorRoomsBuilding1 ?? {}, _floorRoomsBuilding2 ?? {}, favorites) // 传递FavoritesModel
                          else
                            const Center(
                              child: Text(
                                "Oops! No matches found.",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildRoomsList(
      Map<String, List<Room>> floorRoomsBuilding1, Map<String, List<Room>> floorRoomsBuilding2, FavoritesModel favorites) {
    List<Widget> roomCards = [];
    bool hasMatches = false;

    for (var floor in floorRoomsBuilding1.keys) {
      var matchingRooms = floorRoomsBuilding1[floor]!
          .where((room) => room.roomType.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      if (matchingRooms.isNotEmpty) {
        hasMatches = true;
        roomCards.addAll(
          matchingRooms.map<Widget>((room) => _buildRoomCard(room, floor, favorites)).toList(),
        );
      }
    }

    for (var floor in floorRoomsBuilding2.keys) {
      var matchingRooms = floorRoomsBuilding2[floor]!
          .where((room) => room.roomType.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      if (matchingRooms.isNotEmpty) {
        hasMatches = true;
        roomCards.addAll(
          matchingRooms.map<Widget>((room) => _buildRoomCard(room, floor, favorites)).toList(),
        );
      }
    }

    if (!hasMatches) {
      roomCards.add(
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Oops! No matches found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Try adjusting your search.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return roomCards;
  }

  Widget _buildRoomCard(Room room, String floor, FavoritesModel favorites) {
    String roomName = room.roomType;
    String formattedFloor = _formatFloor(floor);
    Color availabilityColor = _getAvailabilityColor(room);
    bool isFavorite = favorites.isRoomFavorite(roomName);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        title: Text('$roomName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            _toggleFavorite(roomName, favorites); 
          },
        ),
        onTap: () {
          _toggleFavorite(roomName, favorites); 
        },
      ),
    );
  }


  void _toggleFavorite(String roomName, FavoritesModel favorites) {
    favorites.toggleRoomFavorite(roomName);
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
    if (availablePercentage > 0.5)
      return Colors.green;
    else if (availablePercentage >= 0.2)
      return Colors.amber;
    else
      return Colors.red;
  }
}
