import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ChatProvider with ChangeNotifier {
  List<String> _chats = [];
  bool _isLoading = false;
  bool _hasChanges = false;
  Timer? _timer;
  final authService = AuthService();

  ChatProvider() {
    _startAutoSave();
  }

  List<String> get chats => _chats;
  bool get isLoading => _isLoading;

  void setChats(List<String> chats) {
    _chats = chats;
    _hasChanges = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void addChat(String chatId) {
    _chats.remove(chatId);
    _chats.insert(0, chatId);
    _hasChanges = true;
    notifyListeners();
  }

  Future<void> fetchChats(String userId) async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final response = await Supabase.instance.client
        .from('User_Info')
        .select('chats')
        .eq('id', userId)
        .single();

    if (response != null) {
      _chats = List<String>.from(response['chats']);
    }

    _isLoading = false;
    _hasChanges = false; // Reset changes flag after fetching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> saveChats(String userId) async {
    if (_hasChanges) {
      await Supabase.instance.client
          .from('User_Info')
          .update({'chats': _chats}).eq('id', userId);
      _hasChanges = false; // Reset changes flag after saving
    }
  }

  void _startAutoSave() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      saveChats(authService.getCurrentUserID()!);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    saveChats(authService.getCurrentUserID()!);
    super.dispose();
  }
}
