import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://finalbackendd.onrender.com/api';
  static late Dio _dio;

  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final errorMessage = error.response?.data?['message'] ?? 
                              error.response?.data ?? '';
          
          // Only handle actual authentication failures
          if (errorMessage.toString().toLowerCase().contains('unauthorized') ||
              errorMessage.toString().toLowerCase().contains('invalid token') ||
              errorMessage.toString().toLowerCase().contains('token expired') ||
              errorMessage.toString().toLowerCase().contains('access denied')) {
            
            print('Authentication token invalid, clearing storage');
            await _clearToken();
          }
        }
        handler.next(error);
      },
    ));
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Generic HTTP methods
  static Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  static Future<Response> post(String endpoint, dynamic data) async {
    return await _dio.post(endpoint, data: data);
  }

  static Future<Response> put(String endpoint, dynamic data) async {
    return await _dio.put(endpoint, data: data);
  }

  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}

// Authentication API
class AuthAPI {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post('/auth/signin', {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await ApiService.post('/auth/signup', userData);
    return response.data;
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final response = await ApiService.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
    return response.data;
  }

  static Future<Map<String, dynamic>> resendOTP(String email) async {
    final response = await ApiService.post('/auth/resend-otp?email=$email', {});
    return response.data;
  }
}

// Backward compatibility for existing code
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await AuthAPI.login(email, password);
    
    // Store token and user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['accessToken']);
    await prefs.setString('user', jsonEncode(data));
    
    return data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await AuthAPI.register(userData);
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final data = await AuthAPI.verifyOTP(email, otp);
    
    // Store token and user data after verification
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['accessToken']);
    await prefs.setString('user', jsonEncode(data));
    
    return data;
  }

  static Future<void> resendOTP(String email) async {
    await AuthAPI.resendOTP(email);
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
