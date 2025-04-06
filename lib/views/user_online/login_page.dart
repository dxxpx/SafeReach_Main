import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackfest/services/service_imp.dart';
import 'package:hackfest/views/notifications.dart';
import 'package:hackfest/views/user_online/welcome_page.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Color _blue = const Color(0XFF4D88D7);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
      TextEditingController(text: "soniya@gmail.com");

  final TextEditingController passwordController =
      TextEditingController(text: "123456");
  String? dvtoken = "";
  Color _statusColor = Colors.green; // Default color is red

  @override
  void initState() {
    super.initState();
    _checkInternetStatus();
  }

  void _checkInternetStatus() async {
    print(
        "Has Intenet Connection ?? ${await InternetConnectionCheckerPlus().hasConnection}");
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

  String dvt = "Device Token";
  void _loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userID = userCredential.user!.uid;
      Service_Imp().storeid(userID);
      // Get the device token
      String? token = await getDeviceToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({
          'deviceToken': token,
        });
      }
      log("User id ${user}");

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      print("Error logging in: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid Login')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "   Login",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 35, color: Colors.white),
        ),
        backgroundColor: _blue,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            const Text(
                              'Welcome Back !!',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1.0),
                            const Text(
                              'Login with your details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            const Divider(
                              thickness: 1.17,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                filled: true,
                                label: const Text('Email'),
                                floatingLabelStyle: const TextStyle(
                                    fontSize: 25, color: Colors.black),
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                icon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.white,
                                floatingLabelStyle: const TextStyle(
                                    fontSize: 25, color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                icon: const Icon(
                                  Icons.password_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () async {
                                String email = emailController.text;
                                String password = passwordController.text;
                                _loginUser(email, password);

                                // String at = await getAccessToken();
                                // sendNotification(at, dt ?? '');
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28.0),
                    const Text(
                      'Don\'t have an Account ?',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 17),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
