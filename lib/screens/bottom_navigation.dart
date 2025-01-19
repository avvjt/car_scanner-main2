import 'package:card_scanner/screens/media.dart';
import 'package:card_scanner/screens/report.dart';
import 'package:card_scanner/screens/team.dart';
import 'package:flutter/material.dart';

import 'history_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Default selected index (Home tab)

  // List of pages corresponding to each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ReportScreen(),
      Media(),
      Team(),
    ];
  }

  // Function to change the selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            // Your navigation logic, e.g., open a drawer or a side menu
          },
        ),
        title: Align(
          alignment: Alignment.center, // Centers the title
          child: Text(
            'Participants',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history, // Replace with your desired icon
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Set background color to black
        selectedItemColor: Colors.white, // Icon color for the selected item
        unselectedItemColor:
            Colors.white.withOpacity(0.6), // Icon color for unselected items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/report.png', // Replace with the actual path to your asset
              height: 24, // Set icon size
              color: Colors.white, // Tint icon to white
            ),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/video.png', // Replace with the actual path to your asset
              height: 24,
              color: Colors.white,
            ),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/assets/group.png', // Replace with the actual path to your asset
              height: 24,
              color: Colors.white,
            ),
            label: 'Team',
          ),
        ],
      ),
    );
  }
}

class MediaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Media Page'));
  }
}

class TeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Team Page'));
  }
}
