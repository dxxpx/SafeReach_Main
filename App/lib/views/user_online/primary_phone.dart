import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hackfest/views/user_online/secondary_phone.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';

import '../../viewmodels/changes.dart';
import '../Uicomponents.dart';

class PrimaryPhone extends StatefulWidget {
  const PrimaryPhone({super.key});

  @override
  _PrimaryPhoneState createState() => _PrimaryPhoneState();
}

class _PrimaryPhoneState extends State<PrimaryPhone> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final Telephony telephony = Telephony.instance;
  String? _generatedOtp;
  Timer? _timer;
  int _start = 60;
  bool _isOtpSent = false;

  String _generateOtp() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString(); // 6 digit OTP
  }

  Future<void> _sendOtp(String phoneNumber) async {
    _generatedOtp = _generateOtp();
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted != null && permissionsGranted) {
      telephony.sendSms(
        to: phoneNumber,
        message: "Your OTP code is $_generatedOtp",
      );
      setState(() {
        _isOtpSent = true;
      });
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS permissions not granted')));
    }
  }

  void _startTimer() {
    _start = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start == 0) {
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _otpController.text.trim();
    if (enteredOtp == _generatedOtp) {
      await context
          .read<MyModel>()
          .regPrimaryPhone(_phoneController.text.trim());
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SecondaryPhone()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appblue,
        title: Text(
          'Primary Phone Number',
          style: appbar_Tstyle,
        ),
        iconTheme: backButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              if (!_isOtpSent) ...[
                SizedBox(
                  height: 200,
                  child: Image.asset(
                      'assets/images/phoneNoImg.png'), // Replace with your image asset path
                ),
                const SizedBox(height: 70),
                Text('Enter Your Phone Number', style: heading_Tstlye()),
                const SizedBox(height: 10),
                Text('We will send you a Verification Code',
                    style: content_Tstlye()),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: t_boxdecor(
                        hintText: "Enter your 10-digit Phone Number",
                        labelText: "Phone Number")),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: buttonStyle(),
                  onPressed: () {
                    String phone = _phoneController.text.trim();
                    if (phone.length != 10 ||
                        !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Please enter a valid 10 digit phone number')));
                      return;
                    }
                    _sendOtp(phone);
                  },
                  child: Text('Send OTP', style: buttonTstyle()),
                ),
              ] else ...[
                SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/otpimg.png'),
                ),
                const SizedBox(height: 70),
                Text('Enter Your Confirmation Code', style: heading_Tstlye()),
                const SizedBox(height: 10),
                Text(
                  'We have sent a confirmation code to your phone number',
                  style: content_Tstlye(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PinCodeTextField(
                  length: 6,
                  appContext: context,
                  controller: _otpController,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 20),
                if (_start > 0)
                  Text(
                    'Resend OTP in $_start seconds',
                    style: const TextStyle(fontSize: 17),
                  )
                else
                  ElevatedButton(
                    style: buttonStyle(),
                    onPressed: () {
                      String phone = _phoneController.text.trim();
                      _sendOtp(phone);
                    },
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: buttonStyle(),
                  onPressed: _verifyOtp,
                  child: const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
