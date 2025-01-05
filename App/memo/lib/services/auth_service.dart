import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:memo/main.dart';
import 'package:memo/services/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    AuthResponse response = await _supabase.auth
        .signInWithPassword(email: email, password: password);
    await NotificationService.initializeFCM(
        _supabase.auth.currentSession?.user.id);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle notification tap
        handleNotificationNavigation(message);
      }
    });

    return response;
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String userName,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'fullName': userName},
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    print(user);
    return user?.userMetadata?['fullName'];
  }

  String? getCurrentUserID() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }
}
