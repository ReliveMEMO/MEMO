import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService { 
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
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
}
