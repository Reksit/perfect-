class Assessment {
  final String id;
  final String title;
  final String description;
  final String domain;
  final String difficulty;
  final int numberOfQuestions;
  final List<Question> questions;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;
  final String? className;
  final List<String>? assignedStudents;

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.difficulty,
    required this.numberOfQuestions,
    required this.questions,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
    this.className,
    this.assignedStudents,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      domain: json['domain'] ?? '',
      difficulty: json['difficulty'] ?? '',
      numberOfQuestions: json['numberOfQuestions'] ?? 0,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? true,
      className: json['className'],
      assignedStudents: (json['assignedStudents'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'domain': domain,
      'difficulty': difficulty,
      'numberOfQuestions': numberOfQuestions,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'isActive': isActive,
      'className': className,
      'assignedStudents': assignedStudents,
    };
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => o.toString())
          .toList() ?? [],
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class AssessmentResult {
  final String id;
  final String assessmentId;
  final String studentId;
  final int score;
  final int totalQuestions;
  final Map<String, int> answers;
  final DateTime submittedAt;
  final Duration timeTaken;

  AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.studentId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.submittedAt,
    required this.timeTaken,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] ?? '',
      assessmentId: json['assessmentId'] ?? '',
      studentId: json['studentId'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      answers: Map<String, int>.from(json['answers'] ?? {}),
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      timeTaken: Duration(seconds: json['timeTaken'] ?? 0),
    );
  }

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}
