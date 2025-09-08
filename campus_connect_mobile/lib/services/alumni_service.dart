import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AlumniService {
  static Future<List<User>> getAlumniDirectory() async {
    final response = await ApiService.get('/api/alumni-directory');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load alumni directory');
    }
  }

  static Future<List<User>> getVerifiedAlumni() async {
    final response = await ApiService.get('/management/alumni-available');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load verified alumni');
    }
  }

  static Future<void> submitEventRequest(Map<String, dynamic> requestData) async {
    final response = await ApiService.post('/api/alumni-events/request', requestData);

    if (response.statusCode != 200 && response.statusCode != 201) {
      ApiService.handleError(response);
      throw Exception('Failed to submit event request');
    }
  }

  static Future<List<Map<String, dynamic>>> getApprovedEvents() async {
    final response = await ApiService.get('/api/alumni-events/approved');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load approved events');
    }
  }

  static Future<void> sendConnectionRequest(String recipientId, String message) async {
    final response = await ApiService.post('/connections/send-request', {
      'recipientId': recipientId,
      'message': message,
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      ApiService.handleError(response);
      throw Exception('Failed to send connection request');
    }
  }

  static Future<List<Map<String, dynamic>>> getConnectionRequests() async {
    final response = await ApiService.get('/connections/pending');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load connection requests');
    }
  }

  static Future<void> acceptConnectionRequest(String connectionId) async {
    final response = await ApiService.post('/connections/$connectionId/accept', {});

    if (response.statusCode != 200) {
      ApiService.handleError(response);
      throw Exception('Failed to accept connection request');
    }
  }

  static Future<void> rejectConnectionRequest(String connectionId) async {
    final response = await ApiService.post('/connections/$connectionId/reject', {});

    if (response.statusCode != 200) {
      ApiService.handleError(response);
      throw Exception('Failed to reject connection request');
    }
  }
}
