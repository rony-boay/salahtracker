import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SalahTrackerScreen(),
    );
  }
}

class SalahTrackerScreen extends StatefulWidget {
  @override
  _SalahTrackerScreenState createState() => _SalahTrackerScreenState();
}

class _SalahTrackerScreenState extends State<SalahTrackerScreen> {
  final String currentDate = DateFormat('EEEE, dd MMMM').format(DateTime.now());
  String location = "Loading location...";

  final List<Map<String, dynamic>> cardsData = [
    {'name': 'Fajr', 'icon': Icons.wb_sunny},
    {'name': 'Dhuhr', 'icon': Icons.wb_cloudy},
    {'name': 'Asr', 'icon': Icons.wb_shade},
    {'name': 'Maghrib', 'icon': Icons.nightlight_round},
    {'name': 'Isha', 'icon': Icons.star},
    {'name': 'Tahajjud', 'icon': Icons.brightness_2},
    {'name': 'Qiyam', 'icon': Icons.access_alarm},
    {'name': 'Witr', 'icon': Icons.light_mode},
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = "Location services are disabled.";
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        location = "Location permissions are permanently denied.";
      });
      return;
    }

    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get city and country from coordinates
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        location = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        location = "Could not fetch location.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(140.0), // Dynamically adjust the AppBar height
        child: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.teal,
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Get the available height dynamically
              double availableHeight = constraints.maxHeight;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Adjust position based on the height
                    SizedBox(
                      height: availableHeight * 0.2,
                    ), // Dynamically adjust padding
                    Text(
                      'Salah Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8), // Fixed space between texts
                    Text(
                      'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentDate,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal[50], // Background color for the drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {},
              ),
              // Additional menu items can be added here
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: cardsData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cardsData[index]['icon'],
                    size: 40,
                    color: Colors.teal,
                  ),
                  SizedBox(height: 8),
                  Text(
                    cardsData[index]['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
