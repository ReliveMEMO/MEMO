import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:memo/pages/convo_page.dart';
import 'package:memo/pages/create_profile.dart';
import 'package:memo/pages/event_page.dart';
import 'package:memo/pages/create_timeline.dart';
import 'package:memo/pages/login_page.dart';
import 'package:memo/pages/memoryReminder_page.dart';
import 'package:memo/pages/my_page.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/pages/signup_page.dart';
import 'package:memo/pages/verify_email_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_gate.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/notification.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/NewMemo.dart';
import 'pages/create_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFicXdiZXBweWxpYXZ2ZnpyeXplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1ODU5NTcsImV4cCI6MjA0OTE2MTk1N30.dKEe4wJ7lJq87GKHzgIR-U-jUYpV3pZWgXQuMpeU9DU",
    url: "https://qbqwbeppyliavvfzryze.supabase.co",
  );

  await Firebase.initializeApp();

  final authService = AuthService();

  if (authService.getCurrentUserID() != null) {
    await NotificationService.initializeFCM(authService.getCurrentUserID());

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle notification tap
        handleNotificationNavigation(message);
      }
    });
  }

  // Listen for notification taps when the app is in the background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // Handle notification tap
    handleNotificationNavigation(message);
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MyApp(),
  ));
}

void handleNotificationNavigation(RemoteMessage message) {
  // Example: Navigate to the chat screen with the senderId from the payload
  final senderId = message.data['senderId'];
  if (senderId != null) {
    routeObserver.navigator
        ?.pushNamed('/chat', arguments: {'senderId': senderId});
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: const authGate(),
      navigatorObservers: [routeObserver],
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(color: Colors.white)),
      routes: {
        '/event': (context) => EventPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/profile': (context) => ProfilePage(),
        '/create-profile': (context) => CreateProfile(),
        '/verify-acc': (context) => VerifyEmailPage(),
        '/chat': (context) => convoPage(),
        '/my-page': (context) => myPage(),
        '/new-memo': (context) => NewMemo(),
        '/create-timeline': (context) => CreateTimeline(),

        //'/memoryReminder': (context) => MemoryReminderPopup(),


        '/create-page': (context) => CreatePage(),

        //Testing the CI pipeline xoxo
      },
    );
  }
}
