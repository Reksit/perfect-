import 'dart:convert';
import '../models/assessment.dart';
import 'api_service.dart';

class AssessmentService {
  static Future<List<Assessment>> getStudentAssessments() async {
    final response = await ApiService.get('/assessments/student');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Assessment.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load assessments');
    }
  }

  static Future<List<Assessment>> getProfessorAssessments() async {
    final response = await ApiService.get('/assessments/professor');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Assessment.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load assessments');
    }
  }

  static Future<Assessment> generateAIAssessment({
    required String domain,
    required String difficulty,
    required int numberOfQuestions,
  }) async {
    final response = await ApiService.post('/assessments/generate-ai', {
      'domain': domain,
      'difficulty': difficulty,
      'numberOfQuestions': numberOfQuestions,
    });

    if (response.statusCode == 200) {
      return Assessment.fromJson(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to generate AI assessment');
    }
  }

  static Future<Assessment> createAssessment(Map<String, dynamic> assessmentData) async {
    final response = await ApiService.post('/assessments', assessmentData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Assessment.fromJson(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to create assessment');
    }
  }

  static Future<AssessmentResult> submitAssessment(
    String assessmentId,
    Map<String, int> answers,
  ) async {
    final response = await ApiService.post('/assessments/$assessmentId/submit', {
      'answers': answers,
      'submittedAt': DateTime.now().toIso8601String(),
    });

    if (response.statusCode == 200) {
      return AssessmentResult.fromJson(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to submit assessment');
    }
  }

  static Future<List<AssessmentResult>> getAssessmentResults(String assessmentId) async {
    final response = await ApiService.get('/assessments/$assessmentId/results');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AssessmentResult.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load assessment results');
    }
  }

  static Future<List<AssessmentResult>> getStudentAssessmentHistory() async {
    final response = await ApiService.get('/students/my-assessment-history');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AssessmentResult.fromJson(json)).toList();
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to load assessment history');
    }
  }

  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final response = await ApiService.get('/assessments/search-students?query=$query');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      ApiService.handleError(response);
      throw Exception('Failed to search students');
    }
  }

  static Future<void> updateAssessment(String assessmentId, Map<String, dynamic> data) async {
    final response = await ApiService.put('/assessments/$assessmentId', data);

    if (response.statusCode != 200) {
      ApiService.handleError(response);
      throw Exception('Failed to update assessment');
    }
  }
}
