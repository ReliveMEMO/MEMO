import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  static Future<void> initializeFCM() async {
    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission();
    print("Permission status: ${settings.authorizationStatus}");

    // Get the FCM token
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Send the token to your backend
    await sendTokenToServer(token);

    // Configure local notifications for foreground messages
    configureLocalNotifications();

    // Listen to token refresh
    messaging.onTokenRefresh.listen((newToken) {
      print("New FCM Token: $newToken");
      sendTokenToServer(newToken);
    });

    // Listen for messages
    listenForMessages();
  }

  static Future<void> sendTokenToServer(String? token) async {
    if (token == null) return;
    print("Send token to backend: $token");
    // Add HTTP logic to send token to your backend
  }

  static void configureLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Replace with your app icon

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
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
