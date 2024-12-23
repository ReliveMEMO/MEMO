import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
