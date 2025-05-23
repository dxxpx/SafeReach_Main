import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hackfest/viewmodels/changes.dart';
import 'package:hackfest/views/user_online/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCA5JJe1J3okqpAVkvICIg3eQB_CvvkJ-M",
      appId: "1:795621005285:android:985e46eb36c7a2171f410c",
      messagingSenderId: "795621005285",
      projectId: "hackfest-d74d3",
      storageBucket: 'gs://hackfest-d74d3.appspot.com',
    ),
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  unawaited(MobileAds.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Changes(
      child: MaterialApp(
        title: 'SafeReach',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Register(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
