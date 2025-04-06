import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackfest/services/service_imp.dart';
import 'package:hackfest/views/admin_online/add_warning_page.dart';
import 'package:intl/intl.dart';
import '../Uicomponents.dart';

class Updates extends StatefulWidget {
  const Updates({super.key});

  @override
  State<Updates> createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Disaster Updates"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('updates')
            .orderBy('timestamp', descending: true)
            .snapshots(),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendNotification();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddWarningPage()));
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
