import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  var _userDetails;

  get userDetails => _userDetails;

  set userDetails(value) {
    _userDetails = value;
    notifyListeners();
  }
}
