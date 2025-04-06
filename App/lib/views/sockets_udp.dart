import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackfest/views/Uicomponents.dart';

class UdpSender extends StatefulWidget {
  const UdpSender({super.key});

  @override
  _UdpSenderState createState() => _UdpSenderState();
}

class _UdpSenderState extends State<UdpSender> {
  String? _selectedOption = "Food";
  RawDatagramSocket? _socket;
  bool _isListening = false;
  List<String> _receivedMessages = ['Currently no received distress signals'];
  String _listeningStatus = "Not listening Right Now";

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendUdpMessage(String message, String ip, int port) async {
    final RawDatagramSocket socket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    socket.send(utf8.encode(message), InternetAddress(ip), port);
    print(" ${message} sent");
    socket.close();
  }

  void _sendMessage() async {
    const String ip = "192.168.4.255";
    final int port = int.tryParse("4210") ?? 0;
    if (_selectedOption != null && ip.isNotEmpty && port > 0) {
      await sendUdpMessage("[rqt]${_selectedOption!}", ip, port);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent: $_selectedOption'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option, and enter valid IP and port'),
          backgroundColor: Colors.deepOrange,
        ),
      );
    }
  }

  void _startListening() async {
    if (_isListening) return;
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4210);
    setState(() {
      _isListening = true;
      _listeningStatus = "Listening for messages...";
    });
    print("Listening for UDP broadcasts...");
    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = _socket!.receive();
        if (datagram != null) {
          String message = utf8.decode(datagram.data);
          print(
              "Received: $message from \${datagram.address}:\${datagram.port}");
          setState(() {
            _receivedMessages.add("${DateTime.now()} -> ${message}");
            if (_receivedMessages.length > 20) {
              _receivedMessages.removeAt(0);
            }
          });
        }
      }
    });
  }

  void _stopListening() {
    if (!_isListening) return;
    _socket?.close();
    setState(() {
      _isListening = false;
      _listeningStatus = "Stopped listening";
    });
    print("Stopped listening for UDP broadcasts.");
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What are you looking for?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              hint: const Text('Select an option'),
              value: _selectedOption!.length > 6 ? "Food" : _selectedOption,
              items:
                  <String>['Food', 'Water', 'Milk', 'Dolo'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send Request'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startListening,
                  child: const Text('Start Listening'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopListening,
                  child: const Text('Stop Listening'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _listeningStatus, // Show the status message
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: Colors.blue),
            ),
            const SizedBox(height: 20),
            distressTile("Save Me", Icons.sos_rounded, () async {
              Future<void> _getCurrentLocation() async {
                try {
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    throw Exception("Location services disabled");
                  }

                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.deniedForever) {
                      throw Exception(
                          "Location permissions permanently denied.");
                    }
                  }

                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  setState(() {
                    _selectedOption =
                        '[dst]${position.latitude}, ${position.longitude}';
                  });
                } catch (e) {
                  print("Error getting location: $e");
                }
              }

              await _getCurrentLocation();
              _sendMessage();
            }, Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              height: 400, // Set a specific height for the ListView
              child: ListView.builder(
                itemCount: _receivedMessages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_receivedMessages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
