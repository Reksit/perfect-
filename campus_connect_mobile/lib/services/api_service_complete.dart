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

// Assessment API
class AssessmentAPI {
  static Future<Map<String, dynamic>> generateAIAssessment({
    required String domain,
    required String difficulty,
    required int numberOfQuestions,
  }) async {
    final response = await ApiService.post('/assessments/generate-ai', {
      'domain': domain,
      'difficulty': difficulty,
      'numberOfQuestions': numberOfQuestions,
    });
    return response.data;
  }

  static Future<List<dynamic>> getStudentAssessments() async {
    final response = await ApiService.get('/assessments/student');
    return response.data;
  }

  static Future<Map<String, dynamic>> submitAssessment(
      String assessmentId, Map<String, dynamic> submission) async {
    final response = await ApiService.post(
        '/assessments/$assessmentId/submit', submission);
    return response.data;
  }

  static Future<Map<String, dynamic>> getAssessmentResults(String assessmentId) async {
    final response = await ApiService.get('/assessments/$assessmentId/results');
    return response.data;
  }

  static Future<Map<String, dynamic>> createAssessment(Map<String, dynamic> data) async {
    final response = await ApiService.post('/assessments', data);
    return response.data;
  }

  static Future<List<dynamic>> getProfessorAssessments() async {
    final response = await ApiService.get('/assessments/professor');
    return response.data;
  }

  static Future<List<dynamic>> searchStudents(String query) async {
    final response = await ApiService.get('/assessments/search-students?query=$query');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateAssessment(
      String assessmentId, Map<String, dynamic> data) async {
    final response = await ApiService.put('/assessments/$assessmentId', data);
    return response.data;
  }
}

// Task API
class TaskAPI {
  static Future<List<dynamic>> getUserTasks() async {
    final response = await ApiService.get('/tasks');
    return response.data;
  }

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final response = await ApiService.post('/tasks', data);
    return response.data;
  }

  static Future<Map<String, dynamic>> generateRoadmap(String taskId) async {
    final response = await ApiService.post('/tasks/$taskId/roadmap', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    final response = await ApiService.put('/tasks/$taskId/status', {'status': status});
    return response.data;
  }
}

// Chat API
class ChatAPI {
  static Future<Map<String, dynamic>> sendAIMessage(String message) async {
    final response = await ApiService.post('/chat/ai', {'message': message});
    return response.data;
  }

  static Future<List<dynamic>> getConversations() async {
    final response = await ApiService.get('/chat/conversations');
    return response.data;
  }

  static Future<List<dynamic>> getAllUsers() async {
    final response = await ApiService.get('/chat/users');
    return response.data;
  }

  static Future<Map<String, dynamic>> markMessagesAsRead(String userId) async {
    final response = await ApiService.put('/chat/mark-read/$userId', {});
    return response.data;
  }

  static Future<List<dynamic>> getChatHistory(String userId) async {
    final response = await ApiService.get('/chat/history/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    final response = await ApiService.post('/chat/send', data);
    return response.data;
  }

  static Future<List<dynamic>> getAlumniDirectory() async {
    final response = await ApiService.get('/users/alumni-directory');
    return response.data;
  }
}

// Management API
class ManagementAPI {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await ApiService.get('/management/stats');
    return response.data;
  }

  static Future<Map<String, dynamic>> getStudentHeatmap(String studentId) async {
    final response = await ApiService.get('/management/student/$studentId/heatmap');
    return response.data;
  }

  static Future<List<dynamic>> getAlumniApplications() async {
    final response = await ApiService.get('/management/alumni');
    return response.data;
  }

  static Future<Map<String, dynamic>> approveAlumni(String alumniId, bool approved) async {
    final response = await ApiService.put('/management/alumni/$alumniId/status', 
        {'approved': approved});
    return response.data;
  }

  static Future<List<dynamic>> searchStudents(String email) async {
    final response = await ApiService.get('/management/students/search?email=$email');
    return response.data;
  }

  static Future<List<dynamic>> getApprovedAlumni() async {
    final response = await ApiService.get('/management/alumni-available');
    return response.data;
  }

  static Future<List<dynamic>> getAllAlumniEventRequests() async {
    final response = await ApiService.get('/management/alumni-event-requests');
    return response.data;
  }

  static Future<Map<String, dynamic>> approveAlumniEventRequest(String requestId) async {
    final response = await ApiService.post('/management/alumni-event-requests/$requestId/approve', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> rejectAlumniEventRequest(String requestId, String? reason) async {
    final response = await ApiService.post('/management/alumni-event-requests/$requestId/reject', 
        {'reason': reason});
    return response.data;
  }

  static Future<Map<String, dynamic>> requestEventFromAlumni(String alumniId, Map<String, dynamic> requestData) async {
    final response = await ApiService.post('/management/request-alumni-event/$alumniId', requestData);
    return response.data;
  }

  static Future<List<dynamic>> getAllManagementEventRequests() async {
    final response = await ApiService.get('/management/management-event-requests');
    return response.data;
  }

  static Future<Map<String, dynamic>> getStudentATSData(String studentId) async {
    final response = await ApiService.get('/management/student/$studentId/ats-data');
    return response.data;
  }

  static Future<List<dynamic>> getAllStudentsATS() async {
    final response = await ApiService.get('/management/students/ats-data');
    return response.data;
  }

  static Future<Map<String, dynamic>> getStudentResume(String studentId, String resumeId) async {
    final response = await ApiService.get('/management/student/$studentId/resume/$resumeId');
    return response.data;
  }

  static Future<dynamic> downloadStudentResume(String studentId, String resumeId) async {
    final response = await ApiService._dio.get('/management/student/$studentId/resume/$resumeId/download',
        options: Options(responseType: ResponseType.bytes));
    return response.data;
  }

  static Future<Map<String, dynamic>> analyzeStudentsBySkills(String query) async {
    final response = await ApiService.post('/management/ai-student-analysis', {'query': query});
    return response.data;
  }

  static Future<List<dynamic>> searchStudentProfiles(Map<String, dynamic> criteria) async {
    final response = await ApiService.post('/management/search-student-profiles', criteria);
    return response.data;
  }
}

// Student API
class StudentAPI {
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await ApiService.get('/students/profile/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/students/my-profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> profileData) async {
    final response = await ApiService.put('/students/my-profile', profileData);
    return response.data;
  }

  static Future<List<dynamic>> getAssessmentHistory([String? userId]) async {
    final endpoint = userId != null 
        ? '/students/assessment-history/$userId' 
        : '/students/my-assessment-history';
    final response = await ApiService.get(endpoint);
    return response.data;
  }
}

// Professor API
class ProfessorAPI {
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await ApiService.get('/professors/profile/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/professors/my-profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> profileData) async {
    final response = await ApiService.put('/professors/my-profile', profileData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getTeachingStats([String? userId]) async {
    final endpoint = userId != null 
        ? '/professors/teaching-stats/$userId' 
        : '/professors/my-teaching-stats';
    final response = await ApiService.get(endpoint);
    return response.data;
  }
}

// Alumni API
class AlumniAPI {
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await ApiService.get('/alumni/profile/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> submitEventRequest(Map<String, dynamic> requestData) async {
    final response = await ApiService.post('/api/alumni-events/request', requestData);
    return response.data;
  }

  static Future<List<dynamic>> getApprovedEvents() async {
    final response = await ApiService.get('/api/alumni-events/approved');
    return response.data;
  }

  static Future<List<dynamic>> getPendingManagementRequests() async {
    final response = await ApiService.get('/alumni/pending-requests');
    return response.data;
  }

  static Future<Map<String, dynamic>> acceptManagementEventRequest(String requestId, String responseMessage) async {
    final response = await ApiService.post('/alumni/accept-management-request/$requestId', 
        {'response': responseMessage});
    return response.data;
  }

  static Future<Map<String, dynamic>> rejectManagementEventRequest(String requestId, String reason) async {
    final response = await ApiService.post('/alumni/reject-management-request/$requestId', 
        {'reason': reason});
    return response.data;
  }

  static Future<Map<String, dynamic>> getAlumniStats() async {
    final response = await ApiService.get('/alumni/stats');
    return response.data;
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/alumni/my-profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> profileData) async {
    final response = await ApiService.put('/alumni/my-profile', profileData);
    return response.data;
  }

  static Future<Map<String, dynamic>> getCompleteProfile(String userId) async {
    final response = await ApiService.get('/alumni-profiles/complete-profile/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> sendConnectionRequest(String recipientId, [String? message]) async {
    final response = await ApiService.post('/connections/send-request', {
      'recipientId': recipientId,
      'message': message ?? 'I would like to connect with you.'
    });
    return response.data;
  }
}

// Activity API
class ActivityAPI {
  static Future<Map<String, dynamic>> logActivity(String type, String description) async {
    final response = await ApiService.post('/activities', {
      'type': type,
      'description': description
    });
    return response.data;
  }

  static Future<List<dynamic>> getUserActivities(String userId, [String? startDate, String? endDate]) async {
    String endpoint = '/activities/user/$userId';
    if (startDate != null || endDate != null) {
      final params = <String>[];
      if (startDate != null) params.add('startDate=$startDate');
      if (endDate != null) params.add('endDate=$endDate');
      endpoint += '?${params.join('&')}';
    }
    final response = await ApiService.get(endpoint);
    return response.data;
  }

  static Future<Map<String, dynamic>> getHeatmapData(String userId) async {
    final response = await ApiService.get('/activities/heatmap/$userId');
    return response.data;
  }
}

// Connection API
class ConnectionAPI {
  static Future<Map<String, dynamic>> sendConnectionRequest(String recipientId, String message) async {
    final response = await ApiService.post('/connections/send-request', {
      'recipientId': recipientId,
      'message': message
    });
    return response.data;
  }

  static Future<Map<String, dynamic>> acceptConnectionRequest(String connectionId) async {
    final response = await ApiService.post('/connections/$connectionId/accept', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> rejectConnectionRequest(String connectionId) async {
    final response = await ApiService.post('/connections/$connectionId/reject', {});
    return response.data;
  }

  static Future<List<dynamic>> getPendingRequests() async {
    final response = await ApiService.get('/connections/pending');
    return response.data;
  }

  static Future<List<dynamic>> getAcceptedConnections() async {
    final response = await ApiService.get('/connections/accepted');
    return response.data;
  }

  static Future<Map<String, dynamic>> getConnectionStatus(String userId) async {
    final response = await ApiService.get('/connections/status/$userId');
    return response.data;
  }

  static Future<Map<String, dynamic>> getConnectionCount() async {
    final response = await ApiService.get('/connections/count');
    return response.data;
  }
}

// Password API
class PasswordAPI {
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await ApiService.post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword
    });
    return response.data;
  }
}

// Resume API
class ResumeAPI {
  static Future<Map<String, dynamic>> uploadResume(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await ApiService._dio.post('/resumes/upload', data: formData);
    return response.data;
  }

  static Future<List<dynamic>> getMyResumes() async {
    final response = await ApiService.get('/resumes/my');
    return response.data;
  }

  static Future<Map<String, dynamic>> getCurrentResume() async {
    final response = await ApiService.get('/resumes/current');
    return response.data;
  }

  static Future<Map<String, dynamic>> getResume(String id) async {
    final response = await ApiService.get('/resumes/$id');
    return response.data;
  }

  static Future<dynamic> downloadResume(String id) async {
    final response = await ApiService._dio.get('/resumes/$id/download',
        options: Options(responseType: ResponseType.bytes));
    return response.data;
  }

  static Future<Map<String, dynamic>> activateResume(String id) async {
    final response = await ApiService.put('/resumes/$id/activate', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> deleteResume(String id) async {
    final response = await ApiService.delete('/resumes/$id');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateResume(String id, Map<String, dynamic> resumeData) async {
    final response = await ApiService.put('/resumes/$id', resumeData);
    return response.data;
  }

  static Future<Map<String, dynamic>> renameResume(String id, String newName) async {
    final response = await ApiService.put('/resumes/$id/rename', {'fileName': newName});
    return response.data;
  }

  static Future<Map<String, dynamic>> analyzeResumeATS(String id) async {
    final response = await ApiService.post('/resumes/$id/analyze-ats', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> sendATSToManagement(String id) async {
    final response = await ApiService.post('/resumes/$id/send-ats-to-management', {});
    return response.data;
  }

  static Future<List<dynamic>> searchBySkill(String skill) async {
    final response = await ApiService.get('/resumes/search?skill=$skill');
    return response.data;
  }

  static Future<Map<String, dynamic>> getUserResume(String userId) async {
    final response = await ApiService.get('/resumes/user/$userId');
    return response.data;
  }
}

// Resume Management API
class ResumeManagementAPI {
  static Future<List<dynamic>> getAllStudentResumes() async {
    final response = await ApiService.get('/resumes/management/all');
    return response.data;
  }

  static Future<List<dynamic>> getResumesWithATS() async {
    final response = await ApiService.get('/resumes/management/with-ats');
    return response.data;
  }

  static Future<Map<String, dynamic>> analyzeStudentProfiles(String query) async {
    final response = await ApiService.post('/resumes/management/analyze-students', {'query': query});
    return response.data;
  }

  static Future<Map<String, dynamic>> markResumeAsSent(String id) async {
    final response = await ApiService.post('/resumes/management/$id/mark-sent', {});
    return response.data;
  }
}

// Alumni Directory API
class AlumniDirectoryAPI {
  static Future<List<dynamic>> getAllVerifiedAlumni() async {
    final response = await ApiService.get('/api/alumni-directory');
    return response.data;
  }

  static Future<List<dynamic>> getAllVerifiedAlumniForAlumni() async {
    final response = await ApiService.get('/api/alumni-directory/for-alumni');
    return response.data;
  }

  static Future<Map<String, dynamic>> getAlumniProfile(String alumniId) async {
    final response = await ApiService.get('/api/alumni-directory/$alumniId');
    return response.data;
  }

  static Future<List<dynamic>> searchAlumni(String query) async {
    final response = await ApiService.get('/api/alumni-directory/search?query=$query');
    return response.data;
  }

  static Future<Map<String, dynamic>> getAlumniStatistics() async {
    final response = await ApiService.get('/api/alumni-directory/statistics');
    return response.data;
  }
}

// Events API
class EventsAPI {
  static Future<List<dynamic>> getApprovedEvents() async {
    try {
      final response = await ApiService.get('/api/events/approved');
      return response.data;
    } catch (error) {
      print('Events API error: $error');
      // Try debug endpoint as fallback
      try {
        final fallbackResponse = await ApiService._dio.get('${ApiService.baseUrl}/debug/events');
        if (fallbackResponse.statusCode == 200) {
          return fallbackResponse.data['events'] ?? [];
        }
      } catch (fallbackError) {
        print('Fallback events API also failed: $fallbackError');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAttendance(String eventId, bool attending) async {
    final response = await ApiService.post('/api/events/$eventId/attendance', 
        {'attending': attending});
    return response.data;
  }
}

// Backward compatibility for existing code
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await AuthAPI.login(email, password);
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await AuthAPI.register(userData);
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    return await AuthAPI.verifyOTP(email, otp);
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
