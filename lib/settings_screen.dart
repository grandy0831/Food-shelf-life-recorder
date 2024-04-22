import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "Unknown";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 57, 119, 173),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text("About SeatMap",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
            leading: const Icon(Icons.info),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),
          ListTile(
            title: const Text("APP Usage help",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
            leading: const Icon(Icons.help),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppHelpPage()));
            },
          ),
          ExpansionTile(
            title: const Text("Other Help",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
            leading: const Icon(Icons.web),
            children: <Widget>[
              ListTile(
                title: const Text("Student Enquiries Centre",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
                onTap: () {
                  _launchURL("https://www.ucl.ac.uk/students/support-and-wellbeing/student-enquiries-centre");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
              ListTile(
                title: const Text("Library support and help",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
                onTap: () {
                  _launchURL("https://www.ucl.ac.uk/library/about-us/getting-help-and-contacting-us");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
              ListTile(
                title: const Text("IT support and help",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
                onTap: () {
                  _launchURL("https://www.ucl.ac.uk/isd/help-support");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
              ListTile(
                title: const Text("UCL Student Privacy",
                style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
                onTap: () {
                  _launchURL("https://www.ucl.ac.uk/legal-services/privacy/ucl-student-privacy");
                },
                trailing: const Icon(Icons.open_in_new),
              ),
            ],
          ),
          ListTile(
            title: const Text("Version",
            style: TextStyle(fontWeight: FontWeight.bold),
            ) ,
            subtitle: Text(_version),
            leading: const Icon(Icons.update),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Can not open $url';
    }
  }
}



class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About SeatMap",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 57, 119, 173),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Application Introduction",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 57, 119, 173)),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.account_balance, size: 30, color: Color.fromARGB(255, 57, 119, 173)),
                        ),
                      ),
                      TextSpan(
                        text: "SeatMap is specifically designed for UCL students and staff to efficiently find and manage seating within campus learning spaces, providing real-time seating availability and navigational assistance.",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Key Features",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 57, 119, 173)),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2.0,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.search, color: Colors.green[700], size: 30),
                    title: const Text("Learning Space Lookup", style: TextStyle(fontSize: 18)),
                    subtitle: const Text("View real-time availability to quickly find open seats across various study spaces."),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.map, color: Colors.orange[700], size: 30),
                    title: const Text("Campus Building Navigation", style: TextStyle(fontSize: 18)),
                    subtitle: const Text("Detailed maps and navigation assist users in swiftly locating their desired study area."),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.red[700], size: 30),
                    title: const Text("Favorites for Rooms and Seats", style: TextStyle(fontSize: 18)),
                    subtitle: const Text("Easily save and manage frequently used spaces and seats."),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "How to Use",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 57, 119, 173)),
            ),
            const SizedBox(height: 8),
            const Card(
              elevation: 2.0,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Upon launching the app, select the desired functionality from the main interface. You can navigate directly using the map to locate buildings or use the search function to quickly verify seating availability in specific study spaces.",
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Future Expansions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 57, 119, 173)),
            ),
            const SizedBox(height: 8),
            const Card(
              elevation: 2.0,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Future updates will include additional campus areas and enhanced user customization features, aiming to provide a more comprehensive and user-friendly experience for managing study spaces.",
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class AppHelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("APP Usage Help",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 57, 119, 173),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Enables scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeader(title: "How to Navigate the App"),
              SectionText(
                "This guide will help you understand how to navigate the SeatMap app and utilize its features to efficiently find and manage study spaces."
              ),
              const Divider(color: Color.fromARGB(255, 57, 119, 173), thickness: 2),
              SectionSubHeader(title: "1. Main Interface"),
              SectionText(
                "Upon launching SeatMap, you'll be presented with the main interface where you can access all the app's features:"
              ),
              BulletList(
                items: [
                  "Building Cards: Display building names, locations, overall seating availability, opening hours, and a map feature for precise navigation.",
                  "Search: Use the search bar to quickly locate specific rooms or buildings."
                ]
              ),
              const Divider(color: Color.fromARGB(255, 57, 119, 173), thickness: 2),
              SectionSubHeader(title: "2. Using the Map"),
              SectionText("The map provides two levels of detail:"),
              BulletList(
                items: [
                  "Building Map: Tap any building to view detailed information and available spaces. Get directions from your current location to the selected building.",
                  "Floor Map: Displays a floor plan. Selecting a room card below the image will highlight the corresponding room on the map, showing you room occupancy and helping you quickly locate available seats."
                ]
              ),
              const Divider(color: Color.fromARGB(255, 57, 119, 173), thickness: 2),
              SectionSubHeader(title: "3. Managing Favorites"),
              SectionText("Easily save and manage your frequently used rooms or seats:"),
              BulletList(
                items: [
                  "Adding to Favorites: Tap the 'favorite' icon next to any room or building to add it to your favorites.",
                  "Accessing Favorites: Go to the 'Favorites' section from the main menu to view or modify your saved spots."
                ]
              ),
              const Divider(color: Color.fromARGB(255, 57, 119, 173), thickness: 2),
              SectionSubHeader(title: "4. Help and Feedback"),
              SectionText(
                "For more detailed assistance or to provide feedback, visit the Help and Feedback section."
              ),
              const Divider(color: Color.fromARGB(255, 57, 119, 173), thickness: 2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget SectionHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 57, 119, 173)),
      ),
    );
  }

  Widget SectionSubHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget SectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget BulletList({required List<String> items}) {
    return Column(
      children: items.map((item) => BulletPointText(item)).toList(),
    );
  }

  Widget BulletPointText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5)),
          )
        ],
      ),
    );
  }
}