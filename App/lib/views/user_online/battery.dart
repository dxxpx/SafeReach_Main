import 'dart:developer';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:hackfest/views/Uicomponents.dart';

import '../notifications.dart';

enum BatteryState {
  charging,
  discharging,
}

class BatteryIndicator extends StatefulWidget {
  final Battery battery;

  const BatteryIndicator({Key? key, required this.battery}) : super(key: key);

  @override
  _BatteryIndicatorState createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  int _batteryLevel = 0;
  final BatteryState _batteryState = BatteryState.discharging;
  late String _batteryLifetime;
  late String _batteryLifetimeSavingMode;
  late String dvtoken;

  void _estimateBatteryLifetime() {
    double estimatedHours = 0;

    if (_batteryState == BatteryState.charging) {
      _batteryLifetime = 'Charging';
    } else {
      // Assuming the device consumes 1% battery per 10 minutes when not charging.
      estimatedHours = _batteryLevel / 15;
      _batteryLifetime = '${estimatedHours.toStringAsFixed(1)} hours remaining';
    }

    // Estimate with power saving mode (assuming 50% battery consumption)
    estimatedHours = _batteryLevel / 4.5;
    _batteryLifetimeSavingMode =
        '${estimatedHours.toStringAsFixed(1)} hours in power saving mode';
  }

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  Future<void> _getBatteryLevel() async {
    int batteryLevel = await widget.battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
      _estimateBatteryLifetime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 120.0,
          lineWidth: 10.0,
          percent: _batteryLevel / 100,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.grey[300]!,
          progressColor: _batteryLevel > 20 ? Colors.green : Colors.red,
          animation: true,
          animationDuration: 1000,
          center: Text(
            "$_batteryLevel%",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _batteryLifetime,
          style: const TextStyle(fontSize: 20),
        ),
        Text(
          _batteryLifetimeSavingMode,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 10,
        ),
        if (_batteryLevel < 90)
          const Text('It is adviced to enable power saving mode'),
        ElevatedButton(
          style: buttonStyle(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Enable Power Saving Mode?',
                  ),
                  content: const Text(
                      'Do you want to enable power saving mode to extend battery life?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Implement logic to enable power saving mode
                        // For demonstration, we'll just show a message

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Power saving mode enabled.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'Enable Power Saving Mode',
            style: buttonTstyle(),
          ),
        ),
      ],
    );
  }
}
