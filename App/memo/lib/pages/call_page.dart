import 'dart:async';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Duration callDuration = Duration(seconds: 0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        callDuration = Duration(seconds: callDuration.inSeconds + 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.purple,
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 50), // Adjust top/bottom padding
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Push content apart
            children: [
              Column(
                children: [
                  const Text(
                    'Sandinu Pinnawala',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDuration(callDuration), // Live call duration
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                          'assets/avatar.png'), // Change to your image
                    ),
                  ),
                ],
              ),

              // Buttons Section with Padding for spacing
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 40), // Adjust bottom spacing
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Mute function
                      },
                      icon: Icon(Icons.mic_off, color: Colors.white),
                      iconSize: 40,
                    ),
                    IconButton(
                      onPressed: () {
                        _timer?.cancel(); // Stop the timer when ending the call
                      },
                      icon: Icon(Icons.call_end, color: Colors.red),
                      iconSize: 50,
                    ),
                    IconButton(
                      onPressed: () {
                        // Speaker function
                      },
                      icon: Icon(Icons.volume_up, color: Colors.white),
                      iconSize: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
