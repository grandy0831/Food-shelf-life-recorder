import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Map<String, int> room = {
  'Workspace 1': 0,
  'Workspace 2': 1,
  'Workspace 3': 2,
  'Workspace 4': 3,
  'Workspace 5': 4,
};

class Room {
  final String roomId;
  final String roomType;
  int totalSeats;
  int occupiedSeats;
  bool isHighlighted;
  Rect area;

  Room({
    required this.roomId,
    required this.roomType,
    this.totalSeats = 0,
    this.occupiedSeats = 0,
    this.isHighlighted = false,
    required this.area,
  });

factory Room.fromJson(Map<String, dynamic> json) {
  // 假设你可以从 json 中获取到位置信息，或者在这里硬编码位置
  // 下面的示例只是硬编码的示例，你需要根据实际应用场景来调整这些值
  Rect area = Rect.fromLTWH(0, 0, 100, 50); // 默认值
  switch (json['description_1']) {
    case 'Workspace 1':
      area = Rect.fromLTWH(10, 10, 100, 50);
      break;
    case 'Workspace 2':
      area = Rect.fromLTWH(120, 10, 100, 50);
      break;
    case 'Workspace 3':
      area = Rect.fromLTWH(230, 10, 100, 50);
      break;
    case 'Workspace 4':
      area = Rect.fromLTWH(340, 10, 100, 50);
      break;
    case 'Workspace 5':
      area = Rect.fromLTWH(450, 10, 100, 50);
      break;
    default:
      break;
  }

  return Room(
    roomId: json['room_id'] ?? '',
    roomType: json['description_1'] ?? 'Unknown Type',
    totalSeats: json['total_seats'] ?? 0,
    occupiedSeats: json['occupied_seats'] ?? 0,
    area: area, // 现在传递实际的area值
  );
}


  void addSeat(bool occupied) {
    totalSeats += 1;
    if (occupied) {
      occupiedSeats += 1;
    }
  }
}

Future<List<Room>> fetchRoomsForFloor(String floorName) async {
  final response = await http.get(Uri.parse('https://uclapi.com/workspaces/sensors?survey_id=111&token=uclapi-47ccfea341ed403-36900a24718217f-25f091619e58a0a-10c2964300e026b'));

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
  Future<List<Room>>? _roomsFuture;
  List<Room>? _rooms;
  bool _isLoading = true;
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _roomsFuture = fetchRoomsForFloor("Second Floor");
    _roomsFuture!.then((roomsLoaded) {
      setState(() {
        _rooms = roomsLoaded;
        _isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "2F - One Pool Street",
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
          Expanded(
            flex: 4,
            child: Image.asset('assets/images/OPS1F.jpg', fit: BoxFit.cover),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              "点击卡片显示对应房间",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Room>>(
                    future: _roomsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Room room = snapshot.data![index];
                            return ListTile(
                              title: Text(room.roomType + " - Available Seats: " + (room.totalSeats - room.occupiedSeats).toString()),
                              onTap: () {
                                setState(() {
                                  // Highlight this room in the image
                                  snapshot.data!.forEach((r) => r.isHighlighted = false);
                                  room.isHighlighted = true;
                                });
                              },
                              tileColor: room.isHighlighted ? Colors.red[100] : Colors.white,
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.done && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                        return const Center(child: Text("当前没有可用的房间。"));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }




  Widget _buildRoomList(List<Room> rooms) {
    return RefreshIndicator(
      onRefresh: () => fetchRoomsForFloor("Second Floor"),
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return buildCard(
            context,
            room.roomType,
            "One Pool Street - 2F, E20 2AF",
            room.totalSeats - room.occupiedSeats,
            room.totalSeats,
            () {},
          );
        },
      ),
    );
  }

  Widget buildCard(
    BuildContext context,
    String roomType,
    String address,
    int availableSeats,
    int totalSeats,
    void Function() onTap,
  ) {
    final double availablePercentage = availableSeats.toDouble() / totalSeats.toDouble();
    Color availabilityColor;
    if (availablePercentage > 0.5) {
      availabilityColor = Colors.green;
    } else if (availablePercentage >= 0.2) {
      availabilityColor = Color.fromARGB(255, 255, 200, 0);
    } else {
      availabilityColor = Colors.red;
    }

    String adjustedBuildingName = roomType;
    if (roomType == "East Campus - Pool St") {
      adjustedBuildingName = "UCL East - One Pool Street";
    } else if (roomType == "East Campus - Marshgate") {
      adjustedBuildingName = "UCL East - Marshgate";
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

      return {
        'isOpenNow': isOpenNow,
        'isOpenToday': isOpenToday,
        'statusText': statusText,
        'statusBoxColor': isOpenNow ? Colors.green : Colors.grey,
        'statusTextColor': isOpenNow ? Colors.white : Colors.red
      };
    }

    Map<String, dynamic> status = getBuildingStatus(adjustedBuildingName);
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
                      ],
                    ),
                  ),
                ],
              ),
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
                        '$availableSeats available / $totalSeats total',
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
                        color: statusTextColor
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
