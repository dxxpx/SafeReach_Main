import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackfest/views/admin_online/admin_page.dart';
import 'package:hackfest/views/user_offline/user_offline.dart';
import 'package:hackfest/views/user_online/login_page.dart';
import 'package:hackfest/views/user_online/primary_phone.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/changes.dart';
import '../Uicomponents.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Color _statusColor = Colors.green; // Default color is red

  @override
  void initState() {
    super.initState();
    _checkInternetStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle permission denied
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return '';
      }
      return '';
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied
      return '';
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.toString());
    return "${position.latitude}, ${position.longitude}";

    // Handle user location
  }

  void _checkInternetStatus() async {
    bool a = await InternetConnectionCheckerPlus().hasConnection;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disaster Relief',
          style: appbar_Tstyle,
        ),
        backgroundColor: appblue,
        actions: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: _statusColor),
            child: Text(_statusColor == Colors.green ? "Online" : "Offline",
                style: appbar_Tstyle),
          ),
          IconButton(
              onPressed: () {
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
                            Navigator.push(
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
              },
              icon: const Icon(
                  color: Colors.white,
                  Icons.signal_cellular_connected_no_internet_0_bar_rounded))
        ],
      ),
      body: _buildRegistrationForm(),
    );
  }

  Widget _buildRegistrationForm() {
    Color appblue = const Color(0XFF4D88D7);
    TextEditingController nameController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Stack(
      children: [
        Column(
          children: [
            _statusColor != Colors.green
                ? Container(
                    padding: const EdgeInsets.all(10),
                    height: 50,
                    width: double.infinity,
                    color: Colors.red,
                    child: const Text(
                      'Click above icon to switch to Offline mode',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ))
                : Container(color: appblue),
            Container(
              height: 200,
              color: appblue,
            ),
            Expanded(
              child: Container(
                color: Colors.white,
              ),
            ),
          ],
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text('Sign Up', style: heading_Tstlye()),
                          const SizedBox(height: 1.0),
                          Text('Tell us about Yourself',
                              style: content_Tstlye()),
                          const SizedBox(height: 16.0),
                          TextFormField(
                              controller: nameController,
                              decoration: t_boxdecor(
                                  labelText: "Name",
                                  icon: Icons.person,
                                  color: appblue,
                                  hintText: "Enter your Name")),
                          const SizedBox(height: 12.0),
                          TextFormField(
                            controller: locationController,
                            decoration: t_boxdecor(
                                hintText: "Get Location",
                                icon: Icons.location_on,
                                color: appblue),
                          ),
                          const SizedBox(height: 6.0),
                          ElevatedButton(
                            style: buttonStyle(),
                            onPressed: () async {
                              String location = await _getCurrentLocation();
                              locationController.text = location;
                            },
                            child: Text(
                              'Get Location',
                              style: buttonTstyle(),
                            ),
                          ),
                          const Divider(
                            thickness: 1.1,
                            color: Colors.black38,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                              controller: emailController,
                              decoration: t_boxdecor(
                                  hintText: "Email Address",
                                  icon: Icons.email_rounded,
                                  color: appblue)),
                          const SizedBox(height: 12.0),
                          TextFormField(
                            controller: passwordController,
                            decoration: t_boxdecor(
                                hintText: "Password",
                                icon: Icons.password_rounded,
                                color: appblue),
                            obscureText: true,
                          ),
                          const SizedBox(height: 6.0),
                          ElevatedButton(
                            style: buttonStyle(),
                            onPressed: () async {
                              await context.read<MyModel>().register1(
                                  nameController.text,
                                  locationController.text,
                                  emailController.text,
                                  passwordController.text);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PrimaryPhone()),
                              );
                            },
                            child: Text('Continue to Register',
                                style: buttonTstyle()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Text(
                    'Already have an Account ?',
                    style: content_Tstlye(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: buttonStyle(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminPage()),
                          );
                        },
                        child: Text('Rescue Crew Login', style: buttonTstyle()),
                      ),
                      const SizedBox(width: 29),
                      ElevatedButton(
                        style: buttonStyle(),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text('Login', style: buttonTstyle()),
                      ),
                    ],
                  ),
                  // ElevatedButton(
                  //   style: buttonStyle(),
                  //   onPressed: () async {
                  //     String? accesstkn = await getAccessToken();
                  //     String dvt =
                  //         "fQCOARCxTZSNssinrkTWcG:APA91bEIeBCAfZXadlOn5uzYzTvp25iFke3S3NySARn9YxgOLZ-Vi0A2GIg7Fwal8E_CDXg-9lfzAvajuc3rcKZ8N9k0aAlU_nwPkJ6R8oRfL3YzMkjDT504h59TzY9om6l6ju4sjeq3";
                  //     sendNotification(accesstkn, dvt);
                  //     print("pressed");
                  //   },
                  //   child: Text('Notif', style: buttonTstyle()),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
