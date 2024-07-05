// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;



  Future<void> initializeApp() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen delay
    await checkAuthStatus();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    if (username == "Admin" && password == "password") {
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      notifyListeners();
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }
}