import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:memo/services/auth_service.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  IO.Socket? _socket;
  String? _userId;
  MediaStream? _localStream;

  // Define the onIncomingCall callback
  Function(String callerId, String? callerProfilePic)? onIncomingCall;

  // Add properties to store the caller and callee's profile pictures
  String? calleeProfilePic;
  String? callerProfilePic;
  String? calleeId; // Add a property to store the callee's ID
  bool isCaller = false; // Add a property to store the caller status

  WebRTCService() {
    _socket = IO.io(
        'wss://memo-backend-9b73024f3215.herokuapp.com/calling',
        <String, dynamic>{
          'transports': ['websocket'],
        });

    _socket!.on('connect', (_) {
      if (_userId != null) {
        _socket!.emit('register', {'type': 'register', 'userId': _userId});
      }
    });

    _socket!.on('connect_error', (error) {
      print('WebSocket connection error: $error');
    });

    _socket!.on('disconnect', (_) {
      print('WebSocket connection closed.');
    });

    _socket!.on('incomingCall', (data) {
      _handleIncomingCall(data);
    });

    _socket!.on('callAnswered', (data) {
      _handleCallAnswered(data);
    });

    _socket!.on('iceCandidate', (data) {
      _handleIceCandidate(data);
    });

    _socket!.on('hangup', (_) {
      _handleHangup();
    });
  }

  void initSocket(String userId) {
    _userId = userId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('register', {'type': 'register', 'userId': _userId});
    }
  }

  Future<void> getUserMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
    } catch (e) {
      print('Error getting user media: $e');
    }
  }

  Future<void> createOffer(String calleeId) async {
    this.calleeId = calleeId; // Store the callee's ID
    isCaller = true; // Set isCaller to true
    await getUserMedia();
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    if (_localStream != null) {
      _peerConnection!.addStream(_localStream!);
    }

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _socket!.emit('iceCandidate',
            {'type': 'iceCandidate', 'candidate': candidate.toMap()});
      }
    };

    // Get callee's profile picture
    calleeProfilePic = await AuthService().getDisplayPicture(calleeId);

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket!.emit('call', {
      'type': 'call',
      'callerId': _userId, // Send caller ID
      'calleeId': calleeId, // Send callee ID
      'offer': offer.toMap(),
      'calleeProfilePic': calleeProfilePic, // Send callee's profile pic
    });
  }

  void _handleIncomingCall(Map<String, dynamic> data) async {
    isCaller = false; // Set isCaller to false
    await getUserMedia();
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    if (_localStream != null) {
      _peerConnection!.addStream(_localStream!);
    }

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _socket!.emit('iceCandidate',
            {'type': 'iceCandidate', 'candidate': candidate.toMap()});
      }
    };

    String callerId = data['callerId'];
    callerProfilePic = await AuthService().getDisplayPicture(callerId);

    RTCSessionDescription offer =
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    await _peerConnection!.setRemoteDescription(offer);

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket!.emit('answer', {'type': 'answer', 'answer': answer.toMap()});

    // Notify UI about incoming call
    onIncomingCall?.call(callerId, callerProfilePic);
  }

  void _handleCallAnswered(Map<String, dynamic> data) async {
    RTCSessionDescription answer =
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
    await _peerConnection!.setRemoteDescription(answer);
  }

  void _handleIceCandidate(Map<String, dynamic> data) async {
    RTCIceCandidate candidate = RTCIceCandidate(data['candidate']['candidate'],
        data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  void _handleHangup() {
    _peerConnection?.close();
    _peerConnection?.dispose();
    _localStream?.dispose();
    _localStream = null;
  }

  void hangup() {
    _socket!.emit('hangup', {'type': 'hangup'});
    _handleHangup();
  }

  MediaStream? get localStream => _localStream;
}
