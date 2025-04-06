import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackfest/services/service_imp.dart';
import 'package:hackfest/views/Uicomponents.dart';
import 'package:hackfest/views/admin_online/placeScreen.dart';
import 'package:hackfest/views/disaster.dart';
import 'package:hackfest/views/emergency_contact.dart';
import 'package:hackfest/views/user_offline/user_offline.dart';
import 'package:hackfest/views/user_online/battery.dart';
import 'package:hackfest/views/user_online/buy.dart';
import 'package:hackfest/views/user_online/leaderboardPage.dart';
import 'package:hackfest/views/user_online/maps_markers.dart';
import 'package:hackfest/views/user_online/my_problems.dart';
import 'package:hackfest/views/user_online/register_page.dart';
import 'package:hackfest/views/user_online/rescue.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:hackfest/views/admin_online/showProvisions.dart';

import '../dialog_flow.dart';
//Added components page

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State with SingleTickerProviderStateMixin {
  final Battery _battery = Battery();
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 1;
  Color _statusColor = Colors.green; // Default color is red
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const List<String> _pageTitles = [
    'Updates',
    'Distress',
    'History',
    'Profile Details',
  ];

  Future<void> _showBatteryAlert(BuildContext context) async {
    int batteryLevel = await _battery.batteryLevel;

    if (batteryLevel <= 100) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Battery Status'),
            actions: [
              BatteryIndicator(battery: _battery),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {}
  }

  void _checkInternetStatus() async {
    print(await InternetConnectionCheckerPlus().hasConnection);
    final listener = InternetConnectionCheckerPlus()
        .onStatusChange
        .listen((InternetConnectionStatus status) {
      setState(() {
        _statusColor = status == InternetConnectionStatus.connected
            ? Colors.green
            : Colors.red;
      });
    });
  }

  Future<void> _getCurrentLocationAndSave() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String location = '${position.latitude}, ${position.longitude}';
    Service_Imp().storelocation(location);
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'location': location,
      });
      setState(() {
        // Update the UI with the new location
      });
    }
  }

  Widget _buildProfileDetails() {
    return Center(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text("User not found");
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String location = data['location'];

          return FutureBuilder<String>(
            future: getLocation(location),
            builder:
                (BuildContext context, AsyncSnapshot<String> locationSnapshot) {
              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (locationSnapshot.hasError) {
                return const Text("Error fetching location");
              }

              String humanReadableLocation =
                  locationSnapshot.data ?? 'Unknown location';

              return profilecard(
                  data['name'],
                  data['adhar'],
                  data['people'].toString(),
                  humanReadableLocation,
                  _getCurrentLocationAndSave,
                  data['primaryphno'],
                  data['secondaryphno']);
            },
          );
        },
      ),
    );
  }

  Widget _buildUpdates() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('updates').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("No updates available."),
          );
        }

        final updates = snapshot.data!.docs;

        return ListView.builder(
          itemCount: updates.length,
          itemBuilder: (BuildContext context, int index) {
            final update = updates[index];
            final bool isSevere = update['isSevere'];

            return updatetile(
                update['disasterType'],
                update['suggestion'],
                DateFormat('dd MMM yyyy, hh:mm a')
                    .format(update['timestamp'].toDate())
                    .toString(),
                isSevere,
                update['location'],
                context);
          },
        );
      },
    );
  }

  Widget _buildHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('distress')
          .where('userID', isEqualTo: user!.uid)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong", style: TextStyle(fontSize: 20)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            "No distress signals found",
            style: TextStyle(fontSize: 20),
          ));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Historytile(data['type'].toString().toUpperCase(),
                data['time'].toDate().toString().substring(0, 16));
          },
        );
      },
    );
  }

  void _addToDistressTable(String type) {
    FirebaseFirestore.instance.collection('distress').add({
      'userID': user!.uid,
      'type': type,
      'time': DateTime.now(),
      // Add more fields as needed
    });
    print('Log : Distress signal ${type} added to table at ${DateTime.now()}');
  }

  Widget _buildDistress() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            distressTile(
                "I am safe but I need food supply", Icons.food_bank_rounded,
                () {
              _showConfirmationDialog("food");
            }, Colors.green),
            const SizedBox(height: 20),
            distressTile(
                "I need Medical Assistance", Icons.local_hospital_rounded, () {
              _showConfirmationDialog("Medical");
            }, Colors.blueAccent),
            const SizedBox(height: 20),
            distressTile("I am at danger, Come and Save me", Icons.sos_rounded,
                () {
              _showConfirmationDialog("sos");
            }, Colors.red),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content:
              Text('Are you sure you want to send a $type distress signal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addToDistressTable(type);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Distress signal sent successfully',
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 3:
        return _buildProfileDetails();
      case 0:
        return _buildUpdates();
      case 1:
        return _buildDistress();
      case 2:
        return _buildHistory();
      default:
        return Container();
    }
  }

  @override
  void initState() {
    _showBatteryAlert(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DisasterContactsApp()));
              },
              child: const Icon(Icons.call),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DialogFlow()));
            },
            child: const Icon(Icons.chat_rounded),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: appbar_Tstyle,
        ),
        backgroundColor: appblue,
        actions: [
          IconButton(
              onPressed: () {
                _showBatteryAlert(context);
              },
              icon: const Icon(
                Icons.battery_alert_sharp,
                color: Colors.white,
              )),
          PopupMenuButton<int>(
            color: Colors.white,
            onSelected: (item) => _onSelected(context, item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 6, child: Text('Inconveniences')),
              const PopupMenuItem<int>(
                  value: 8, child: Text('Nearby Help Stations')),
              const PopupMenuItem<int>(value: 7, child: Text('Provisions')),
              const PopupMenuItem<int>(value: 4, child: Text('Show on Map')),
              const PopupMenuItem<int>(value: 0, child: Text('Go Offline')),
              const PopupMenuItem<int>(value: 1, child: Text('Rescue Others')),
              const PopupMenuItem<int>(value: 2, child: Text('Buy Products')),
              const PopupMenuItem<int>(value: 5, child: Text('Disaster Guide')),
              const PopupMenuItem<int>(value: 9, child: Text('LeaderBoard')),
              const PopupMenuItem<int>(value: 3, child: Text('Logout')),
            ],
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey, //
        selectedItemColor: appblue, // <-- add this
        showUnselectedLabels: true,
        backgroundColor: Colors.black12,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Distress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Switch Mode'),
              content: const Text(
                  'Are you sure you want to switch to Offline Mode?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const UserOffline()));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switching to Offline Mode'),
                      ),
                    );
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Rescue()));
        break;
      case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Buy()));
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Register()));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const GoogleMapScreen(
                  lat: 0,
                  long: 0,
                )));
        break;
      case 5:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisasterInfoPage(
                  disasters: disasters,
                )));
        break;
      case 6:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyProblemsPage()));
        break;
      case 7:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ProvisionListPage()));
      case 8:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const placeScreen1()));
      case 9:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LeaderboardPage()));
    }
  }
}
