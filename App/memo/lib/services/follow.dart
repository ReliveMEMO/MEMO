import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  final supabase = Supabase.instance.client;
  final authSevice = AuthService();

  Future<bool> handleFollow(String userId) async {
    try {
      final response = await supabase.from('user_following').insert({
        'follower_id': authSevice.getCurrentUserID(),
        'followed_id': userId,
        'created_at': DateTime.now().toIso8601String()
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkFollow(String userId) async {
    try {
      final response = await supabase
          .from('user_following')
          .select()
          .eq('follower_id', authSevice.getCurrentUserID() ?? '')
          .eq('followed_id', userId)
          .single();

      print(response);
      return response.isNotEmpty;
    } catch (e) {
      // Handle the error appropriately, e.g., log it or rethrow
      return false;
    }
  }
}
