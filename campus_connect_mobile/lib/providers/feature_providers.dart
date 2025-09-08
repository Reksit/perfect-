import 'package:flutter/material.dart';
import '../services/api_extensions.dart';

class ProfessorProvider extends ChangeNotifier {
  Map<String, dynamic>? _professorProfile;
  List<dynamic> _courses = [];
  List<dynamic> _upcomingClasses = [];
  Map<String, dynamic>? _studentAnalytics;
  int _totalStudents = 0;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get professorProfile => _professorProfile;
  List<dynamic> get courses => _courses;
  List<dynamic> get upcomingClasses => _upcomingClasses;
  Map<String, dynamic>? get studentAnalytics => _studentAnalytics;
  int get totalStudents => _totalStudents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfessorProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _professorProfile = await ProfessorAPI.getMyProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfessorCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, use mock data since getMyCourses doesn't exist
      _courses = [
        {'id': '1', 'name': 'Data Structures', 'studentCount': 45},
        {'id': '2', 'name': 'Algorithms', 'studentCount': 38},
        {'id': '3', 'name': 'Database Systems', 'studentCount': 52},
      ];
      _totalStudents = _courses.fold(0, (sum, course) => sum + (course['studentCount'] as int? ?? 0));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUpcomingClasses() async {
    try {
      // For now, use mock data since getUpcomingClasses doesn't exist
      _upcomingClasses = [
        {
          'courseName': 'Data Structures',
          'room': 'Room 101',
          'time': '10:00 AM',
          'duration': '1h 30m',
          'studentCount': 45,
        },
        {
          'courseName': 'Algorithms',
          'room': 'Room 203',
          'time': '2:00 PM',
          'duration': '1h 30m',
          'studentCount': 38,
        },
      ];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStudentAnalytics() async {
    try {
      // Use existing teaching stats method or mock data
      _studentAnalytics = await ProfessorAPI.getTeachingStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class AlumniProvider extends ChangeNotifier {
  List<dynamic> _verifiedAlumni = [];
  Map<String, dynamic>? _alumniProfile;
  Map<String, dynamic>? _alumniStats;
  List<dynamic> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get verifiedAlumni => _verifiedAlumni;
  Map<String, dynamic>? get alumniProfile => _alumniProfile;
  Map<String, dynamic>? get alumniStats => _alumniStats;
  List<dynamic> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVerifiedAlumni() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _verifiedAlumni = await AlumniDirectoryAPI.getAllVerifiedAlumni();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlumniProfile(String alumniId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alumniProfile = await AlumniDirectoryAPI.getAlumniProfile(alumniId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlumniStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alumniStats = await AlumniAPI.getAlumniStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingRequests = await AlumniAPI.getPendingManagementRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> searchAlumni(String query) async {
    try {
      return await AlumniDirectoryAPI.searchAlumni(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendConnectionRequest(String recipientId, [String? message]) async {
    try {
      await AlumniAPI.sendConnectionRequest(recipientId, message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ConnectionProvider extends ChangeNotifier {
  List<dynamic> _pendingRequests = [];
  List<dynamic> _acceptedConnections = [];
  Map<String, dynamic>? _connectionCount;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get pendingRequests => _pendingRequests;
  List<dynamic> get acceptedConnections => _acceptedConnections;
  Map<String, dynamic>? get connectionCount => _connectionCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingRequests = await ConnectionAPI.getPendingRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAcceptedConnections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _acceptedConnections = await ConnectionAPI.getAcceptedConnections();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConnectionCount() async {
    try {
      _connectionCount = await ConnectionAPI.getConnectionCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getConnectionStatus(String userId) async {
    try {
      return await ConnectionAPI.getConnectionStatus(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendConnectionRequest(String recipientId, String message) async {
    try {
      await ConnectionAPI.sendConnectionRequest(recipientId, message);
      await loadPendingRequests(); // Refresh pending requests
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptConnectionRequest(String connectionId) async {
    try {
      await ConnectionAPI.acceptConnectionRequest(connectionId);
      await loadPendingRequests(); // Refresh pending requests
      await loadAcceptedConnections(); // Refresh accepted connections
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectConnectionRequest(String connectionId) async {
    try {
      await ConnectionAPI.rejectConnectionRequest(connectionId);
      await loadPendingRequests(); // Refresh pending requests
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ManagementProvider extends ChangeNotifier {
  Map<String, dynamic>? _dashboardStats;
  List<dynamic> _alumniApplications = [];
  List<dynamic> _alumniEventRequests = [];
  List<dynamic> _managementEventRequests = [];
  List<dynamic> _studentsATS = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<dynamic> get alumniApplications => _alumniApplications;
  List<dynamic> get alumniEventRequests => _alumniEventRequests;
  List<dynamic> get managementEventRequests => _managementEventRequests;
  List<dynamic> get studentsATS => _studentsATS;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardStats = await ManagementAPI.getDashboardStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlumniApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alumniApplications = await ManagementAPI.getAlumniApplications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlumniEventRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alumniEventRequests = await ManagementAPI.getAllAlumniEventRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentsATS() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _studentsATS = await ManagementAPI.getAllStudentsATS();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveAlumni(String alumniId, bool approved) async {
    try {
      await ManagementAPI.approveAlumni(alumniId, approved);
      await loadAlumniApplications(); // Refresh applications
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> approveAlumniEventRequest(String requestId) async {
    try {
      await ManagementAPI.approveAlumniEventRequest(requestId);
      await loadAlumniEventRequests(); // Refresh requests
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectAlumniEventRequest(String requestId, String? reason) async {
    try {
      await ManagementAPI.rejectAlumniEventRequest(requestId, reason);
      await loadAlumniEventRequests(); // Refresh requests
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<dynamic>> searchStudents(String email) async {
    try {
      return await ManagementAPI.searchStudents(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeStudentsBySkills(String query) async {
    try {
      return await ManagementAPI.analyzeStudentsBySkills(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  List<dynamic> _conversations = [];
  List<dynamic> _messages = [];
  Map<String, dynamic>? _activeConversation;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get conversations => _conversations;
  List<dynamic> get messages => _messages;
  Map<String, dynamic>? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await ChatAPI.getAllConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await ChatAPI.getMessages(conversationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String conversationId, String message) async {
    try {
      await ChatAPI.sendMessage(conversationId, message);
      await loadMessages(conversationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createConversation(String recipientId) async {
    try {
      final conversation = await ChatAPI.createConversation(recipientId);
      _activeConversation = conversation;
      await loadConversations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setActiveConversation(Map<String, dynamic> conversation) {
    _activeConversation = conversation;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class EventsProvider extends ChangeNotifier {
  List<dynamic> _allEvents = [];
  List<dynamic> _myEvents = [];
  List<dynamic> _upcomingEvents = [];
  Map<String, dynamic>? _eventDetails;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get allEvents => _allEvents;
  List<dynamic> get myEvents => _myEvents;
  List<dynamic> get upcomingEvents => _upcomingEvents;
  Map<String, dynamic>? get eventDetails => _eventDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allEvents = await EventsAPI.getAllEvents();
      _upcomingEvents = _allEvents.where((event) {
        final eventDate = DateTime.tryParse(event['date'] ?? '');
        return eventDate != null && eventDate.isAfter(DateTime.now());
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myEvents = await EventsAPI.getMyEvents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEventDetails(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventDetails = await EventsAPI.getEventDetails(eventId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      await EventsAPI.registerForEvent(eventId);
      await loadAllEvents();
      await loadMyEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await EventsAPI.createEvent(eventData);
      await loadAllEvents();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ResumeProvider extends ChangeNotifier {
  Map<String, dynamic>? _myResume;
  List<dynamic> _resumeTemplates = [];
  List<dynamic> _skills = [];
  List<dynamic> _experiences = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get myResume => _myResume;
  List<dynamic> get resumeTemplates => _resumeTemplates;
  List<dynamic> get skills => _skills;
  List<dynamic> get experiences => _experiences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyResume() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myResume = await ResumeAPI.getMyResume();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResumeTemplates() async {
    try {
      _resumeTemplates = [
        {'id': 1, 'name': 'Classic', 'preview': 'classic_preview.png'},
        {'id': 2, 'name': 'Modern', 'preview': 'modern_preview.png'},
        {'id': 3, 'name': 'Creative', 'preview': 'creative_preview.png'},
      ];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateResume(Map<String, dynamic> resumeData) async {
    try {
      _myResume = await ResumeAPI.updateMyResume(resumeData);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addExperience(Map<String, dynamic> experience) async {
    try {
      await ResumeAPI.addExperience(experience);
      await loadMyResume();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSkill(String skill) async {
    try {
      await ResumeAPI.addSkill(skill);
      await loadMyResume();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ConnectionsProvider extends ChangeNotifier {
  List<dynamic> _myConnections = [];
  List<dynamic> _pendingRequests = [];
  List<dynamic> _sentRequests = [];
  List<dynamic> _suggestedConnections = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get myConnections => _myConnections;
  List<dynamic> get pendingRequests => _pendingRequests;
  List<dynamic> get sentRequests => _sentRequests;
  List<dynamic> get suggestedConnections => _suggestedConnections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyConnections() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myConnections = await ConnectionAPI.getMyConnections();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests() async {
    try {
      _pendingRequests = await ConnectionAPI.getPendingRequests();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSentRequests() async {
    try {
      _sentRequests = await ConnectionAPI.getSentRequests();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSuggestedConnections() async {
    try {
      _suggestedConnections = await ConnectionAPI.getSuggestedConnections();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendConnectionRequest(String userId, [String? message]) async {
    try {
      await ConnectionAPI.sendConnectionRequest(userId, message);
      await loadSentRequests();
      await loadSuggestedConnections();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.acceptConnectionRequest(requestId);
      await loadMyConnections();
      await loadPendingRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.rejectConnectionRequest(requestId);
      await loadPendingRequests();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
