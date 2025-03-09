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

  Future<String> checkFollow(String userId) async {
    try {
      final response = await supabase
          .from('user_following')
          .select()
          .eq('follower_id', authSevice.getCurrentUserID() ?? '')
          .eq('followed_id', userId)
          .single();

      await Future.delayed(Duration(milliseconds: 50));

      if (response['following'] == 'requested') {
        return 'requested';
      } else {
        return 'following';
      }
    } catch (e) {
      // Handle the error appropriately, e.g., log it or rethrow
      return 'not-following';
    }
  }

  Future<int> getFollowersCount(String userId) async {
    try {
      final response = await supabase
          .from('user_following')
          .select()
          .eq('followed_id', userId)
          .eq('following', 'following')
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await supabase
          .from('user_following')
          .select()
          .eq('follower_id', userId)
          .eq('following', 'following')
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> requestHandle(String userId, bool accept) async {
    try {
      if (accept) {
        final response = await supabase
            .from('user_following')
            .upsert({'following': 'following'})
            .eq('follower_id', userId)
            .eq('followed_id', authSevice.getCurrentUserID() ?? '');
      } else {
        final response = await supabase
            .from('user_following')
            .delete()
            .eq('follower_id', userId)
            .eq('followed_id', authSevice.getCurrentUserID() ?? '');
      }
    } catch (e) {
      print(e);
    }
  }
}
