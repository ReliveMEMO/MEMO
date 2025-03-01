import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketManager {
  WebSocketChannel? _channel;
  String _userId = '';

  void connect(String userId) {
    _userId = userId;
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://memo-backend-9b73024f3215.herokuapp.com/calling'),
    );
    _channel!.stream.listen(_handleMessage);
    _registerUser();
  }

  void _registerUser() {
    _sendMessage({
      'type': 'register',
      'userId': _userId,
    });
  }

  void _sendMessage(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  void _handleMessage(dynamic message) {
    final data = jsonDecode(message);
    switch (data['type']) {
      case 'incomingCall':
        // Handle incoming call
        break;
      case 'callAnswered':
        // Handle call answered
        break;
      case 'iceCandidate':
        // Handle ICE candidate
        break;
      case 'hangup':
        // Handle hangup
        break;
    }
  }

  void initiateCall(String calleeId, String offer) {
    _sendMessage({
      'type': 'call',
      'callerId': _userId,
      'calleeId': calleeId,
      'offer': offer,
    });
  }

  void answerCall(String answer) {
    _sendMessage({
      'type': 'answer',
      'answer': answer,
    });
  }

  void sendIceCandidate(String candidate) {
    _sendMessage({
      'type': 'iceCandidate',
      'candidate': candidate,
    });
  }

  void hangup() {
    _sendMessage({
      'type': 'hangup',
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}
