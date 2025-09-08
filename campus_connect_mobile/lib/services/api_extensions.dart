import 'api_service.dart';

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

  static Future<Map<String, dynamic>> analyzeStudentsBySkills(String query) async {
    final response = await ApiService.post('/management/ai-student-analysis', {'query': query});
    return response.data;
  }

  static Future<List<dynamic>> searchStudentProfiles(Map<String, dynamic> criteria) async {
    final response = await ApiService.post('/management/search-student-profiles', criteria);
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
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAttendance(String eventId, bool attending) async {
    final response = await ApiService.post('/api/events/$eventId/attendance', 
        {'attending': attending});
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

  static Future<List<dynamic>> getConnections() async {
    final response = await ApiService.get('/connections');
    return response.data;
  }

  static Future<List<dynamic>> getSentRequests() async {
    final response = await ApiService.get('/connections/sent');
    return response.data;
  }

  static Future<List<dynamic>> getSuggestedConnections() async {
    final response = await ApiService.get('/connections/suggestions');
    return response.data;
  }

  static Future<Map<String, dynamic>> removeConnection(String connectionId) async {
    final response = await ApiService.delete('/connections/$connectionId');
    return response.data;
  }

  static Future<Map<String, dynamic>> cancelSentRequest(String requestId) async {
    final response = await ApiService.delete('/connections/sent/$requestId');
    return response.data;
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    final response = await ApiService.get('/users/search?q=${Uri.encodeComponent(query)}');
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

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await ApiService.get('/alumni/my-profile');
    return response.data;
  }

  static Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> profileData) async {
    final response = await ApiService.put('/alumni/my-profile', profileData);
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
}

// Event API
class EventAPI {
  static Future<List<dynamic>> getAllEvents() async {
    final response = await ApiService.get('/events');
    return response.data;
  }

  static Future<List<dynamic>> getMyEvents() async {
    final response = await ApiService.get('/events/my');
    return response.data;
  }

  static Future<List<dynamic>> getRegisteredEvents() async {
    final response = await ApiService.get('/events/registered');
    return response.data;
  }

  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    final response = await ApiService.post('/events', eventData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final response = await ApiService.put('/events/$eventId', eventData);
    return response.data;
  }

  static Future<void> deleteEvent(String eventId) async {
    await ApiService.delete('/events/$eventId');
  }

  static Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    final response = await ApiService.post('/events/$eventId/register', {});
    return response.data;
  }

  static Future<Map<String, dynamic>> unregisterFromEvent(String eventId) async {
    final response = await ApiService.post('/events/$eventId/unregister', {});
    return response.data;
  }

  static Future<List<dynamic>> getEventAttendees(String eventId) async {
    final response = await ApiService.get('/events/$eventId/attendees');
    return response.data;
  }

  static Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    final response = await ApiService.get('/events/$eventId');
    return response.data;
  }

  static Future<List<dynamic>> getUpcomingEvents() async {
    final response = await ApiService.get('/events/upcoming');
    return response.data;
  }

  static Future<List<dynamic>> getEventsByCategory(String category) async {
    final response = await ApiService.get('/events/category/$category');
    return response.data;
  }
}

// Resume API
class ResumeAPI {
  static Future<Map<String, dynamic>?> getUserResume() async {
    try {
      final response = await ApiService.get('/resume');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getResumeTemplates() async {
    final response = await ApiService.get('/resume/templates');
    return response.data;
  }

  static Future<Map<String, dynamic>> saveResume(Map<String, dynamic> resumeData) async {
    final response = await ApiService.post('/resume', resumeData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateResume(Map<String, dynamic> resumeData) async {
    final response = await ApiService.put('/resume', resumeData);
    return response.data;
  }

  static Future<String> generateResumePDF(String templateId) async {
    final response = await ApiService.post('/resume/generate-pdf', {'templateId': templateId});
    return response.data['pdfUrl'];
  }

  static Future<List<dynamic>> getResumeHistory() async {
    final response = await ApiService.get('/resume/history');
    return response.data;
  }

  static Future<Map<String, dynamic>> shareResume(String recipientEmail) async {
    final response = await ApiService.post('/resume/share', {'email': recipientEmail});
    return response.data;
  }

  static Future<void> deleteResume() async {
    await ApiService.delete('/resume');
  }
}
