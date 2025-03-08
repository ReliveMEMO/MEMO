import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  static Future<void> initializeFCM(userId) async {
    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission();
    print("Permission status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the FCM token
      String? token;
      if (Platform.isAndroid) {
        token = await messaging.getToken();
        print("FCM Token: $token");
      } else if (Platform.isIOS) {
        token = await messaging.getAPNSToken();
        if (token == null) {
          print("Failed to get APNS Token");
        } else {
          print("APNS Token: $token");
        }
      }

      // Send the token to your backend
      await sendTokenToServer(token, userId);

      // Configure local notifications for foreground messages
      configureLocalNotifications();

      // Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        print("New FCM Token: $newToken");
        sendTokenToServer(newToken, userId);
      });

      // Listen for messages
      listenForMessages();
    } else {
      print("User declined or has not accepted notification permissions");
    }
  }

  static Future<void> sendTokenToServer(String? token, String userId) async {
    if (token == null) return;

    final url = Uri.parse(
        'https://memo-backend-9b73024f3215.herokuapp.com/api/fcm-token');
    final body = jsonEncode({
      'userId': userId,
      'fcmToken': token,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('Token sent successfully');
    } else {
      print('Failed to send token: ${response.statusCode}');
    }
  }

  static void configureLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Replace with your app icon

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    localNotificationsPlugin.initialize(initializationSettings);
  }

  static void listenForMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");

      // Show a local notification
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('channel_id', 'channel_name',
              importance: Importance.high, priority: Priority.high);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      localNotificationsPlugin.show(
        0, // Notification ID
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification opened: ${message.notification?.title}");
      // Navigate to a specific screen if required
    });
  }
}
