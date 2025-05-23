import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackfest/views/user_online/add_problem.dart';
import 'package:hackfest/views/user_online/all_problems.dart';

import '../Uicomponents.dart';

class MyProblemsPage extends StatefulWidget {
  const MyProblemsPage({super.key});

  @override
  _MyProblemsPageState createState() => _MyProblemsPageState();
}

class _MyProblemsPageState extends State<MyProblemsPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteProblem(String docId) async {
    await FirebaseFirestore.instance.collection('problems').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Problems', style: appbar_Tstyle),
        iconTheme: backButton(color: Colors.white),
        backgroundColor: appblue,
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AllProblemsPage()));
              },
              child: const Text("View All Problems")),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('problems')
                  .where('userid', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    'No problems posted by you',
                    style: content_Tstlye(),
                  ));
                }
                final problems = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: problems.length,
                  itemBuilder: (context, index) {
                    final problem = problems[index];
                    return ListTile(
                      title: Text(problem['description']),
                      subtitle: Text(problem['location']),
                      leading: problem['imageUrl'] != null
                          ? Image.network(
                              problem['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await _deleteProblem(problem.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: appblue,
                                content:
                                    const Text('Problem marked as rectified')),
                          );
                        },
                        child: const Text('Rectified'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SubmitProblemPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
