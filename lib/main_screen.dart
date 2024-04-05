import 'package:flutter/material.dart';
import 'one_pool_street_map_screen.dart'; 
import 'marshgate_map_screen.dart'; 
import 'settings_screen.dart'; 


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
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                buildCard(
                  context, 
                  'UCL East - One Pool Street', 
                  '1 Pool St, London E20 2AF', 
                  'Seat availability here...', 
                  'Map for OPS', 
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnePoolStreetMapScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                buildCard(
                  context, 
                  'UCL East - Marshgate', 
                  '7 Sidings St, London E20 2AE', 
                  'Seat availability here...', 
                  'Map for Marshgate',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MarshgateMapScreen()),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      );
    }

  Widget buildCard(BuildContext context, String buildingName, String address, String seatAvailability, String mapText, void Function() onTap) {
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
                          buildingName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // If you have specific navigation logic for the button, add it here.
                  },
                ),
              ],
            ),
            const Divider(),
            ListTile(
              title: Text(seatAvailability),
              // Add your seat availability logic here if necessary.
            ),
            InkWell(
              onTap: onTap,
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
