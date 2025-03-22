import 'dart:ffi';

import 'package:memo/services/auth_service.dart';
import 'package:memo/services/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final authService = AuthService();
  final notificationService = NotificationService();
  final supabase = Supabase.instance.client;

  Future<bool> handleLike(
      String postId, String ownerId, int likes, List likedUsers) async {
    try {
      final response = await supabase.from('Post_Table').update({
        'likes': likes,
        'liked_by': [...likedUsers, authService.getCurrentUserID()]
      }).eq("post_id", postId);

      await notificationService.sendNotificationsCom("Like", ownerId);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> handleUnLike(
      String postId, String ownerId, int likes, List likedUsers) async {
    try {
      final updatedLikedUsers = likedUsers
          .where((userId) => userId != authService.getCurrentUserID())
          .toList();

      final response = await supabase
          .from('Post_Table')
          .update({'likes': likes, 'liked_by': updatedLikedUsers}).eq(
              "post_id", postId);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
