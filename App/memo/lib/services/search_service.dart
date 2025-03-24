import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchService {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await supabase
        .from('User_Info')
        .select()
        .ilike('full_name', '%$query%')
        .neq('id', authService.getCurrentUserID()!);

    return response as List<Map<String, dynamic>>;
  }

  Future<List<Map<String, dynamic>>> searchPages(String query) async {
    final response = await supabase
        .from('page_table')
        .select()
        .ilike('page_name', '%$query%');

    return response as List<Map<String, dynamic>>;
  }

  Future<List<Map<String, dynamic>>> searchEvents(String query) async {
    final response =
        await supabase.from('events').select().ilike('event_name', '%$query%');

    return response as List<Map<String, dynamic>>;
  }
}
