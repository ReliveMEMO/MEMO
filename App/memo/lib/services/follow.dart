import 'package:memo/services/auth_service.dart';
import 'package:memo/services/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  final supabase = Supabase.instance.client;
  final authSevice = AuthService();
  final notificationService = NotificationService();
  Future<bool> handleFollow(String userId, bool privateProfile) async {
    try {

      if (privateProfile) {
        final response = await supabase.from('user_following').insert({
          'follower_id': authSevice.getCurrentUserID(),
          'followed_id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'following': 'requested',
        });

        await notificationService.sendNotificationsCom(
            "Follow-Request", userId);
      } else {
        final response = await supabase.from('user_following').insert({
          'follower_id': authSevice.getCurrentUserID(),
          'followed_id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'following': 'following',
        });
        await notificationService.sendNotificationsCom("Follow", userId);
      }

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
          .eq('follower_id', authService.getCurrentUserID() ?? '')
          .eq('followed_id', userId)
          .single();

      await Future.delayed(Duration(milliseconds: 50));

      if (response['following'] == 'requested') {
        return 'requested';
      } else {
        return 'following';
      }
    } catch (e) {
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

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final List<dynamic> response = await supabase
          .from('user_following')
          .select(
              'follower_id, User_Info!user_following_follower_id_fkey(id,full_name, profile_pic)')
          .eq('followed_id', userId)
          .eq('following', 'following');

      print("Fetched Followers: $response");

      // Ensure the response is a list of maps
      return response.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching followers: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final List<dynamic> response = await supabase
          .from('user_following')
          .select(
              'followed_id, User_Info!user_following_followed_id_fkey(id,full_name,profile_pic)')
          .eq('follower_id', userId)
          .eq('following', 'following');

      print("Fetched Following: $response");

      // Ensure the response is a list of maps
      return response.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching following: $e");
      return [];

  Future<void> requestHandle(String userId, bool accept) async {
    try {
      if (accept) {
        final response = await supabase
            .from('user_following')
            .update({'following': 'following'})
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
