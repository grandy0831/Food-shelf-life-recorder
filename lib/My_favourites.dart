import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_model.dart';
import 'one_pool_street_map_screen.dart'; 
import 'marshgate_map_screen.dart'; 
import 'MarshgateFloorScreen.dart';
import 'OnePoolStreetFloorScreen.dart';
import 'error_screen.dart'; 

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  _MyFavoritesScreenState createState() => _MyFavoritesScreenState();
}


class _MyFavoritesScreenState extends State<MyFavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    double tabWidth = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorites',
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
          Container(
            color: Colors.grey[300],
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(0),
              ),
              labelColor: Colors.black, 
                labelStyle: const TextStyle( 
                fontWeight: FontWeight.bold,
                fontSize: 18, 
              ),
              unselectedLabelColor: Colors.grey[800], 
                unselectedLabelStyle: const TextStyle( 
                fontWeight: FontWeight.normal, 
                fontSize: 16, 
              ),
              tabs: [
                SizedBox(width: tabWidth, child: const Tab(text: 'Buildings')),
                SizedBox(width: tabWidth, child: const Tab(text: 'Rooms')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BuildingsTab(),
                RoomsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class BuildingsTab extends StatelessWidget {
  const BuildingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
      builder: (context, favorites, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: favorites.favoriteBuildings.length,
          itemBuilder: (context, index) {
            final building = favorites.favoriteBuildings[index];
            String location = 'Unknown location';
            Widget detailScreen = const ErrorScreen();  
            Widget floorScreen = const ErrorScreen();   

            if (building == 'UCL East - OPS') {
              location = '1 Pool St, London E20 2AF';
              detailScreen = const OnePoolStreetMapScreen();
              floorScreen = const OnePoolStreetFloorScreen();
            } else if (building == 'UCL East - Marshgate') {
              location = '7 Sidings St, London E20 2AE';
              detailScreen = const MarshgateMapScreen();
              floorScreen = const MarshgateFloorScreen();
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 2,  
              color: Colors.white,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)  
            ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8, right: 12.0),
                            child: Text(
                              building,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8.0, right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$location", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const Divider(indent: 10.0, endIndent: 10.0, thickness: 1.0),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                            child: Text('View Building Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16.0, bottom: 4.0),
                            child: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => detailScreen)),
                  ),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text('View Floor Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => floorScreen)),
                  ),
                  const Divider(indent: 10.0, endIndent: 10.0, thickness: 1.0),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0,  bottom: 8.0),
                            child: Text('Remove from Favorites', style: TextStyle(fontSize: 16)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16.0, bottom: 8.0),
                            child: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => favorites.removeBuilding(building),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesModel>(
      builder: (context, favorites, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: favorites.favoriteRooms.length,
          itemBuilder: (context, index) {
            final room = favorites.favoriteRooms[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                title: Text(room, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Room Details: [Details Here]"),
                    InkWell(
                      child: Text("View Room Details", style: TextStyle(color: Colors.blueAccent)),
                      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailsPage(room))),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () => favorites.removeRoom(room),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
