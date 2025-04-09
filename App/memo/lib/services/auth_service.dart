import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:memo/main.dart';
import 'package:memo/services/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<AuthResponse> signInWithGoogle() async {
    // Web Client ID that registered with Google Cloud.
    const webClientId =
        '1047457511880-jeorj6kvv0ddfneplopr4km951tsbhh3.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      //clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<String?> getDisplayPicture(String userId) async {
    if (userId.isEmpty) {
      print('Error: userId is empty');
      return null;
    }

    final response = await _supabase
        .from('User_Info')
        .select('profile_pic')
        .eq('id', userId)
        .maybeSingle();

    if (response == null || response['avatar_url'] == null) {
      print('Error fetching display picture');
      return null;
    }

    return response['avatar_url'] as String?;
  }

  Future<String?> getDisplayName(String userId) async {
    if (userId.isEmpty) {
      print('Error: userId is empty');
      return null;
    }

    final response = await _supabase
        .from('User_Info')
        .select('full_name')
        .eq('id', userId)
        .maybeSingle();

    if (response == null || response['full_name'] == null) {
      print('Error fetching display name');
      return null;
    }

    return response['full_name'] as String?;
  }

  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
