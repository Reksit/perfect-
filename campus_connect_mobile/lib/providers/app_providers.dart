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

  int get pendingGradingCount {
    return _professorAssessments.where((assessment) => 
      assessment['status'] == 'submitted' || assessment['needsGrading'] == true
    ).length;
  }

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
