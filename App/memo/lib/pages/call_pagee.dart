import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memo/services/webrtc_service.dart';
import 'package:memo/services/auth_service.dart'; // Import AuthService to get user names

class CallScreen extends StatefulWidget {
  final WebRTCService webrtcService;

  CallScreen({required this.webrtcService});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Duration callDuration = Duration(seconds: 0);
  Timer? _timer;
  String? profilePic;
  String? displayName; // Add a variable to store the display name

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Set up the onIncomingCall callback
    widget.webrtcService.onIncomingCall = (callerId, callerProfilePic) async {
      if (!widget.webrtcService.isCaller) {
        String? name =
            await AuthService().getDisplayName(callerId); // Fetch caller's name
        setState(() {
          profilePic = callerProfilePic;
          displayName = name;
        });
      }
    };

    // If the user is the caller, get the callee's profile picture and name
    if (widget.webrtcService.isCaller) {
      _fetchCalleeDetails();
    }
  }

  Future<void> _fetchCalleeDetails() async {
    String? name = await AuthService()
        .getDisplayName(widget.webrtcService.calleeId!); // Fetch callee's name
    setState(() {
      profilePic = widget.webrtcService.calleeProfilePic;
      displayName = name;
    });
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
                  Text(
                    displayName ??
                        'Unknown', // Display the fetched name or 'Unknown' if null
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: profilePic != null
                          ? NetworkImage(profilePic!)
                          : AssetImage('assets/avatar.png'),
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
                        widget.webrtcService.hangup();
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
