import 'dart:convert';
import 'api_service.dart';

class ChatService {
  static Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await ApiService.get('/chat/conversations');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load conversations');
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    final response = await ApiService.get('/chat/history/$userId');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load chat history');
    }
  }

  static Future<void> sendMessage(String recipientId, String message) async {
    final response = await ApiService.post('/chat/send', {
      'recipientId': recipientId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (response.statusCode != 200 && response.statusCode != 201) {
      ApiService.handleError(response);
      throw Exception('Failed to send message');
    }
  }

  static Future<Map<String, dynamic>> sendAIMessage(String message) async {
    final response = await ApiService.post('/chat/ai', {
      'message': message,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to send AI message');
    }
  }

  static Future<void> markMessagesAsRead(String userId) async {
    final response = await ApiService.put('/chat/mark-read/$userId', {});

    if (response.statusCode != 200) {
      ApiService.handleError(response);
      throw Exception('Failed to mark messages as read');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await ApiService.get('/chat/users');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load users');
    }
  }
}
