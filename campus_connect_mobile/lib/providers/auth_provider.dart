import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isValidating = false;

  User? get user => _user;
  String? get token => _token;
  String? get userRole => _user?.role;
  bool get isLoading => _isLoading || _isValidating;
  bool get isLoggedIn => _user != null && _token != null;

  AuthProvider() {
    _validateStoredAuth();
  }

  Future<void> _validateStoredAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');
      final storedUser = prefs.getString('user');

      if (storedToken != null && storedUser != null) {
        try {
          // Parse and validate token structure
          final tokenParts = storedToken.split('.');
          if (tokenParts.length == 3) {
            final payload = jsonDecode(utf8.decode(base64Decode(base64.normalize(tokenParts[1]))));
            final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
            
            // Check if token is expired (with 1 minute buffer)
            if (payload['exp'] != null && payload['exp'] > (currentTime + 60)) {
              _token = storedToken;
              _user = User.fromJson(jsonDecode(storedUser));
              print('Valid token found, user authenticated');
            } else {
              // Token is expired or about to expire
              print('Token expired, clearing storage');
              await _clearStorage();
            }
          } else {
            // Invalid token format
            print('Invalid token format, clearing storage');
            await _clearStorage();
          }
        } catch (error) {
          // Error parsing token, clear storage
          print('Error parsing token, clearing storage: $error');
          await _clearStorage();
        }
      } else {
        print('No stored token or user found');
      }
    } catch (error) {
      print('Error validating stored auth: $error');
      await _clearStorage();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
  }

  Future<void> login(String email, String password) async {
    _isValidating = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      
      final userData = User(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        role: response['role'],
        department: response['department'],
        className: response['className'],
        phoneNumber: response['phoneNumber'],
        verified: response['verified'] ?? false,
      );

      _user = userData;
      _token = response['accessToken'];
      
      // Store data locally for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['accessToken']);
      await prefs.setString('user', jsonEncode(userData.toJson()));
      
      print('Login successful, user data: ${userData.toJson()}');
    } catch (error) {
      print('Login error: $error');
      rethrow;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isValidating = true;
    notifyListeners();

    try {
      await AuthService.register(userData);
    } catch (error) {
      print('Registration error: $error');
      rethrow;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    _isValidating = true;
    notifyListeners();

    try {
      final response = await AuthService.verifyOTP(email, otp);
      
      final userData = User(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        role: response['role'],
        department: response['department'],
        className: response['className'],
        phoneNumber: response['phoneNumber'],
        verified: response['verified'] ?? false,
      );

      _user = userData;
      _token = response['accessToken'];
      
      // Store data locally for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['accessToken']);
      await prefs.setString('user', jsonEncode(userData.toJson()));
      
      print('OTP verification successful, user data: ${userData.toJson()}');
    } catch (error) {
      print('OTP verification error: $error');
      rethrow;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  Future<void> resendOTP(String email) async {
    await AuthService.resendOTP(email);
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    print('Logging out user');
    
    await AuthService.logout();
    
    // Clear any app-specific storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('completedAssessments');
    
    // Clear any other app-specific storage
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('app_') || key.startsWith('assessment_')) {
        await prefs.remove(key);
      }
    }
    
    _user = null;
    _token = null;

    _isLoading = false;
    notifyListeners();
  }

  String? getDashboardRoute() {
    if (_user == null) return null;

    switch (_user!.role.toLowerCase()) {
      case 'student':
        return '/student-dashboard';
      case 'professor':
        return '/professor-dashboard';
      case 'alumni':
        return '/alumni-dashboard';
      case 'management':
        return '/management-dashboard';
      default:
        return '/student-dashboard';
    }
  }
}
