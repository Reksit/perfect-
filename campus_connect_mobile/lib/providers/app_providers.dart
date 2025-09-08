import 'package:flutter/material.dart';
import '../services/api_extensions.dart';

class AssessmentProvider extends ChangeNotifier {
  List<dynamic> _studentAssessments = [];
  List<dynamic> _professorAssessments = [];
  Map<String, dynamic>? _currentAssessment;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get studentAssessments => _studentAssessments;
  List<dynamic> get professorAssessments => _professorAssessments;
  Map<String, dynamic>? get currentAssessment => _currentAssessment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudentAssessments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _studentAssessments = await AssessmentAPI.getStudentAssessments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfessorAssessments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _professorAssessments = await AssessmentAPI.getProfessorAssessments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> generateAIAssessment({
    required String domain,
    required String difficulty,
    required int numberOfQuestions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AssessmentAPI.generateAIAssessment(
        domain: domain,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
      );
      _currentAssessment = result;
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitAssessment(
      String assessmentId, Map<String, dynamic> submission) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AssessmentAPI.submitAssessment(assessmentId, submission);
      // Refresh assessments after submission
      await loadStudentAssessments();
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createAssessment(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AssessmentAPI.createAssessment(data);
      // Refresh assessments after creation
      await loadProfessorAssessments();
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class TaskProvider extends ChangeNotifier {
  List<dynamic> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await TaskAPI.getUserTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await TaskAPI.createTask(data);
      await loadTasks(); // Refresh tasks
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    try {
      final result = await TaskAPI.updateTaskStatus(taskId, status);
      await loadTasks(); // Refresh tasks
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateRoadmap(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await TaskAPI.generateRoadmap(taskId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ChatProvider extends ChangeNotifier {
  List<dynamic> _conversations = [];
  List<dynamic> _users = [];
  List<dynamic> _chatHistory = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get conversations => _conversations;
  List<dynamic> get users => _users;
  List<dynamic> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await ChatAPI.getConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await ChatAPI.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chatHistory = await ChatAPI.getChatHistory(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    try {
      final result = await ChatAPI.sendMessage(data);
      // Refresh conversations
      await loadConversations();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendAIMessage(String message) async {
    try {
      return await ChatAPI.sendAIMessage(message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String userId) async {
    try {
      await ChatAPI.markMessagesAsRead(userId);
      await loadConversations(); // Refresh conversations
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
