import 'package:flutter/material.dart';

class Map272Screen extends StatefulWidget {
  @override
  _Map272ScreenState createState() => _Map272ScreenState();
}

class Room {
  String name;
  Rect area; // 定义房间在图片中的区域
  bool isHighlighted;

  Room({required this.name, this.isHighlighted = false, required this.area});
}

class _Map272ScreenState extends State<Map272Screen> {
  final List<Room> rooms = [
    Room(name: "Room A - Study Area", area: Rect.fromLTWH(10, 10, 100, 50)),
    Room(name: "Room B - Library", area: Rect.fromLTWH(120, 10, 100, 50)),
    Room(name: "Room C - Computer Lab", area: Rect.fromLTWH(230, 10, 100, 50)),
    Room(name: "Room D - Conference Room", area: Rect.fromLTWH(340, 10, 100, 50)),
    Room(name: "Room E - Lounge Area", area: Rect.fromLTWH(450, 10, 100, 50)),
  ];

  Room? highlightedRoom; // Track the currently highlighted room

  void highlightRoom(Room? room) {
    setState(() {
      highlightedRoom = room; 
      rooms.forEach((r) => r.isHighlighted = (r == highlightedRoom));
    });
  }

  bool isInRoomTap(Rect roomArea, TapDownDetails details) {
    return roomArea.contains(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "1F - One Pool Street",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 57, 119, 173),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: (TapDownDetails details) {
          bool tappedInRoom = false;
          for (var room in rooms) {
            if (isInRoomTap(room.area, details)) {
              highlightRoom(room);
              tappedInRoom = true;
              break;
            }
          }
          if (!tappedInRoom) {
            highlightRoom(null); // De-highlight all rooms if tapped outside any room
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.4,
                child: InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(20.0),
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      Image.asset('assets/images/OPS1F.jpg', fit: BoxFit.cover),
                      ...rooms.map((room) => Positioned(
                        left: room.area.left,
                        top: room.area.top,
                        width: room.area.width,
                        height: room.area.height,
                        child: Opacity(
                          opacity: room.isHighlighted ? 0.5 : 0.0, // Highlighted rooms are semi-transparent
                          child: Container(color: Colors.red),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
              Container(
                height: screenHeight * 0.6,
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: rooms[index].isHighlighted ? Colors.redAccent : Colors.white,
                      child: ListTile(
                        title: Text(rooms[index].name),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () => highlightRoom(rooms[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
