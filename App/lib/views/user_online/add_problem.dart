import 'dart:io';
import 'package:hackfest/views/Uicomponents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class SubmitProblemPage extends StatefulWidget {
  const SubmitProblemPage({super.key});

  @override
  _SubmitProblemPageState createState() => _SubmitProblemPageState();
}

class _SubmitProblemPageState extends State<SubmitProblemPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Position? _currentPosition;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    print("Entered get current location ${DateTime.now()}");
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("Got current location ${DateTime.now()}");
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toString()}');
      final uploadTask = storageRef.putFile(File(_image!.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitProblem() async {
    final user = _auth.currentUser;
    final imageUrl = await _uploadImage();
    final timestamp = DateTime.now().toUtc();

    await FirebaseFirestore.instance.collection('problems').add({
      'description': _descriptionController.text,
      'location': _currentPosition != null
          ? 'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}'
          : 'Please select your Location',
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'rectified': false,
      'userid': user?.uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Problem submitted successfully!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
    // Clear inputs
    _descriptionController.clear();
    setState(() {
      _image = null;
      _currentPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Problem', style: buttonTstyle()),
        backgroundColor: appblue,
        iconTheme: backButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Description',
                  style: heading_Tstlye(), textAlign: TextAlign.start),
              const SizedBox(height: 3),
              TextField(
                controller: _descriptionController,
                decoration: t_boxdecor(hintText: "Describe your problem here"),
              ),
              const SizedBox(height: 20),
              if (_image != null) ...[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                style: buttonStyle(),
                onPressed: _pickImage,
                child: Text('Pick Image', style: buttonTstyle()),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Location: "),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _currentPosition != null
                          ? 'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}'
                          : 'Location not available',
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: buttonStyle(),
                onPressed: _getCurrentLocation,
                child: Text('Get Current Location', style: buttonTstyle()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonStyle(),
                onPressed: _submitProblem,
                child: Text('Submit Problem', style: buttonTstyle()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
