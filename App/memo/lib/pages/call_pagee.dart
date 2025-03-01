import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:memo/services/auth_service.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallScreen extends StatefulWidget {
  final String calleeId;
  final String calleeProfilePic;

  const CallScreen({
    Key? key,
    required this.calleeId,
    required this.calleeProfilePic,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Duration callDuration = Duration(seconds: 0);
  Timer? _timer;
  String? profilePic;
  String? displayName;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  WebSocketChannel? callingChannel;
  String _callingStatus = 'Idle'; // 'Idle', 'Calling', 'Ringing', 'In Call'
  bool _inCalling = false;
  bool _isIncomingCall = false; // Track if it's an incoming call
  String? _incomingCallerId;
  String? _incomingOffer;

  @override
  void initState() {
    super.initState();
    final String userId = AuthService().getCurrentUserID()!;
    _initializeCallingWebSocket(userId); // Pass userId instead of calleeId
    _getDisplayName();
  }

  Future<void> _getDisplayName() async {
    String? name = await AuthService().getDisplayName(widget.calleeId);
    setState(() {
      displayName = name;
      profilePic = widget.calleeProfilePic;
    });
  }

  Future<void> _initializeWebRTC() async {
    try {
      await _createPeerConnection();
      await _getUserMedia();
    } catch (e) {
      print("Error initializing WebRTC: $e");
    }
  }

  Future<void> _createPeerConnection() async {
    try {
      final config = <String, dynamic>{
        'iceServers': [
          {
            'urls': ['stun:stun.l.google.com:19302']
          },
        ]
      };

      _peerConnection = await createPeerConnection(config);

      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        _sendIceCandidate(candidate);
      };
    } catch (e) {
      print("Error creating peer connection: $e");
    }
  }

  Future<void> _getUserMedia() async {
    try {
      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': false, // Disable video
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      if (!_isIncomingCall) {
        _initiateCall(widget.calleeId);
      }
    } catch (e) {
      print('Error getting user media: $e');
    }
  }

  void _initializeCallingWebSocket(String userId) {
    try {
      callingChannel = WebSocketChannel.connect(
        Uri.parse('wss://memo-backend-9b73024f3215.herokuapp.com/calling'),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final registerMessage = jsonEncode({
          "type": "register",
          "userId": userId,
        });
        callingChannel?.sink.add(registerMessage);
        print("User registered with ID: $userId");
      });

      callingChannel?.stream.listen((message) {
        print("Received WebSocket message: $message"); // Log incoming messages
        _handleCallingMessage(message);
      }, onError: (error) {
        print("WebSocket error: $error");
      }, onDone: () {
        print("WebSocket connection closed.");
      });
    } catch (e, stackTrace) {
      print("WebSocket initialization error: $e\n$stackTrace");
    }
  }

  void _handleCallingMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      print("Received message: $data"); // Log the message

      switch (data['type']) {
        case 'incomingCall':
          _handleIncomingCall(data['callerId'], data['offer']);
          break;
        case 'callAnswered':
          _handleCallAnswered(data['answer']);
          break;
        case 'iceCandidate':
          _addIceCandidate(data['candidate']);
          break;
        case 'hangup':
          _hangup();
          break;
        default:
          print("Unknown message type: ${data['type']}");
          break;
      }
    } catch (e) {
      print("Error handling calling message: $e");
    }
  }

  // Initiate a call
  Future<void> _initiateCall(String calleeId) async {
    setState(() {
      _callingStatus = 'Calling'; // Update calling status to "Calling"
    });
    await _createOffer();
  }

  // Create offer
  Future<void> _createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      _sendCallOffer(offer);
      setState(() {
        _inCalling = true;
      });
    } catch (e) {
      print('Error creating offer: $e');
    }
  }

  // Handle incoming call
  Future<void> _handleIncomingCall(String callerId, String offer) async {
    setState(() {
      _callingStatus = 'Ringing'; // Update calling status to "Ringing"
      _isIncomingCall = true; // Mark as incoming call
      _incomingCallerId = callerId;
      _incomingOffer = offer;
    });

    // Show a dialog or UI element to allow the user to accept or reject the call
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Incoming Call"),
          content: Text("You have an incoming call from $callerId"),
          actions: [
            TextButton(
              child: Text("Reject"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _hangup(); // Hangup the call
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Answer"),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _answerCall(callerId, offer); // Answer the call
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _answerCall(String callerId, String offer) async {
    try {
      await _initializeWebRTC(); // Initialize WebRTC if it's not already
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer, 'offer'),
      );
      await _createAnswer(callerId);
      setState(() {
        _inCalling = true;
      });
    } catch (e) {
      print('Error handling incoming call: $e');
    }
  }

  // Create answer
  Future<void> _createAnswer(String callerId) async {
    try {
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _sendCallAnswer(answer);
      _startTimer();
      setState(() {
        _callingStatus = 'In Call'; // Update calling status to "In Call"
      });
    } catch (e) {
      print('Error creating answer: $e');
    }
  }

  // Handle call answered
  Future<void> _handleCallAnswered(String answer) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer, 'answer'),
      );
      _startTimer();
      setState(() {
        _callingStatus = 'In Call'; // Update calling status to "In Call"
      });
    } catch (e) {
      print('Error handling call answered: $e');
    }
  }

  // Add ICE candidate
  Future<void> _addIceCandidate(String candidate) async {
    try {
      dynamic session = jsonDecode(candidate);
      RTCIceCandidate iceCandidate = RTCIceCandidate(
        session['candidate'],
        session['sdpMid'],
        session['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(iceCandidate);
    } catch (e) {
      print('Error adding ICE candidate: $e');
    }
  }

  // Send call offer
  void _sendCallOffer(RTCSessionDescription offer) {
    try {
      final String? callerId = AuthService().getCurrentUserID();
      final message = jsonEncode({
        'type': 'call',
        'callerId': callerId,
        'calleeId': widget.calleeId,
        'offer': offer.sdp,
      });
      callingChannel?.sink.add(message);
      print("Sending call offer: $message"); // Log the message
    } catch (e) {
      print("Error sending call offer: $e");
    }
  }

  // Send call answer
  void _sendCallAnswer(RTCSessionDescription answer) {
    try {
      final message = jsonEncode({
        'type': 'answer',
        'answer': answer.sdp,
      });
      callingChannel?.sink.add(message);
      print("Sending call answer: $message"); // Log the message
    } catch (e) {
      print("Error sending call answer: $e");
    }
  }

  // Send ICE candidate
  void _sendIceCandidate(RTCIceCandidate candidate) {
    try {
      final message = jsonEncode({
        'type': 'iceCandidate',
        'candidate': candidate.toMap(),
      });
      callingChannel?.sink.add(message);
      print("Sending ICE candidate: $message"); // Log the message
    } catch (e) {
      print("Error sending ICE candidate: $e");
    }
  }

  // Hangup call
  void _hangup() {
    try {
      _stopTimer();
      setState(() {
        _inCalling = false;
        _callingStatus = 'Idle';
      });
      _peerConnection?.close();
      _localStream?.dispose();
      _peerConnection = null;
      _localStream = null;

      if (callingChannel != null) {
        callingChannel?.sink.add(jsonEncode({'type': 'hangup'}));
        callingChannel?.sink.close();
        callingChannel = null;
      }
      Navigator.pop(context); // Navigate back to the previous page
    } catch (e) {
      print("Error during hangup: $e");
    }
  }

  // Start the timer
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        callDuration = Duration(seconds: callDuration.inSeconds + 1);
      });
    });
  }

  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      callDuration = Duration(seconds: 0);
    });
  }

  // Format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    try {
      _timer?.cancel();
      callingChannel?.sink.close();
      _peerConnection?.close();
      _localStream?.dispose();
      super.dispose();
    } catch (e) {
      print("Error during dispose: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  displayName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _callingStatus == 'In Call'
                      ? _formatDuration(callDuration)
                      : _callingStatus == 'Ringing'
                          ? 'Ringing...'
                          : 'Calling...',
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
                        : AssetImage('assets/images/user.png') as ImageProvider,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
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
                      _hangup();
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
    );
  }
}
