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
    return await _supabase.auth
        .signUp(email: email, password: password, data: {'userName': userName});
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<AuthResponse> signInWithGoogle() async {
    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '1047457511880-jeorj6kvv0ddfneplopr4km951tsbhh3.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
    //const iosClientId = 'my-ios.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

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

  // // New method for Google Sign-In
  // Future<AuthResponse> signInWithGoogle() async {
  //   return await _supabase.auth.signInWithOAuth(Provider.google);
  // }

  //  // New method for Google Sign-In
  // Future<bool> signInWithGoogle() async {
  //   try {
  //     // Call the signInWithOAuth method and wait for its response
  //     bool result = await _supabase.auth.signInWithOAuth(
  //       OAuthProvider.google, // Use OAuthProvider.google

  //       redirectTo: 'io.supabase.flutter://login-callback',// Replace with your actual redirect URL
  //     );
  //     return result; // Return the boolean indicating success
  //   } catch (e) {
  //     print('Error during Google Sign-In: $e');
  //     return false; // Return false in case of error
  //   }
  // }
}
