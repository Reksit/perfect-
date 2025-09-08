import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_extensions.dart';

class AIAssessmentScreen extends StatefulWidget {
  const AIAssessmentScreen({super.key});

  @override
  State<AIAssessmentScreen> createState() => _AIAssessmentScreenState();
}

class _AIAssessmentScreenState extends State<AIAssessmentScreen> {
  Map<String, dynamic>? _assessment;
  bool _loading = false;
  bool _isActive = false;
  int _currentQuestion = 0;
  Map<int, int> _answers = {};
  Timer? _timer;
  int _timeLeft = 0;
  bool _showResults = false;
  Map<String, dynamic>? _results;

  String _selectedDomain = '';
  String _selectedDifficulty = '';
  int _numberOfQuestions = 5;

  final List<String> _domains = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography'
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateAssessment() async {
    if (_selectedDomain.isEmpty || _selectedDifficulty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select domain and difficulty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final assessment = await AssessmentAPI.generateAIAssessment(
        domain: _selectedDomain,
        difficulty: _selectedDifficulty,
        numberOfQuestions: _numberOfQuestions,
      );

      setState(() {
        _assessment = assessment;
        _isActive = true;
        _currentQuestion = 0;
        _answers = {};
        _timeLeft = (_assessment!['timeLimit'] as int? ?? 30) * 60; // minutes to seconds
        _showResults = false;
        _loading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _submitAssessment();
      }
    });
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestion] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < (_assessment!['questions'] as List).length - 1) {
      setState(() {
        _currentQuestion++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  Future<void> _submitAssessment() async {
    _timer?.cancel();

    setState(() {
      _loading = true;
    });

    try {
      final submissionData = {
        'assessmentId': _assessment!['id'],
        'answers': _answers.entries.map((entry) => {
          'questionIndex': entry.key,
          'selectedOption': entry.value,
        }).toList(),
        'timeSpent': (_assessment!['timeLimit'] as int) * 60 - _timeLeft,
      };

      final result = await AssessmentAPI.submitAssessment(
        _assessment!['id'].toString(),
        submissionData,
      );

      setState(() {
        _results = result;
        _isActive = false;
        _showResults = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetAssessment() {
    setState(() {
      _assessment = null;
      _isActive = false;
      _currentQuestion = 0;
      _answers = {};
      _timeLeft = 0;
      _showResults = false;
      _results = null;
      _selectedDomain = '';
      _selectedDifficulty = '';
      _numberOfQuestions = 5;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'AI Assessment',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: _timeLeft < 300 ? Colors.red : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _timeLeft < 300 ? Colors.white : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_timeLeft),
                    style: TextStyle(
                      color: _timeLeft < 300 ? Colors.white : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
            ),
            SizedBox(height: 16),
            Text(
              'Generating AI Assessment...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_showResults) {
      return _buildResultsView();
    }

    if (_isActive && _assessment != null) {
      return _buildQuestionView();
    }

    return _buildSetupView();
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'AI-Powered Assessment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create personalized assessments with AI-generated questions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Assessment Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Domain Selection
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subject Domain',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDomain.isEmpty ? null : _selectedDomain,
                      hint: const Text('Select a domain'),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: _domains.map((domain) {
                        return DropdownMenuItem(
                          value: domain,
                          child: Text(domain),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDomain = value ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Difficulty Selection
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Difficulty Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _difficulties.map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    Color getColor() {
                      switch (difficulty) {
                        case 'Easy':
                          return Colors.green;
                        case 'Medium':
                          return Colors.orange;
                        case 'Hard':
                          return Colors.red;
                        default:
                          return Colors.grey;
                      }
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDifficulty = difficulty;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? getColor() : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? getColor() : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            difficulty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Number of Questions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Number of Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _numberOfQuestions.toDouble(),
                        min: 5,
                        max: 20,
                        divisions: 15,
                        activeColor: const Color(0xFF1565C0),
                        onChanged: (value) {
                          setState(() {
                            _numberOfQuestions = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_numberOfQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generateAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Generate AI Assessment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    final questions = _assessment!['questions'] as List;
    final question = questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / questions.length;

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestion + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${(_currentQuestion + 1)}/${questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // Question Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Options
                      ...List.generate(
                        (question['options'] as List).length,
                        (index) {
                          final option = question['options'][index];
                          final isSelected = _answers[_currentQuestion] == index;
                          
                          return GestureDetector(
                            onTap: () => _selectAnswer(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF1565C0).withOpacity(0.1)
                                    : Colors.grey[50],
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFF1565C0)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected 
                                          ? const Color(0xFF1565C0)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFF1565C0)
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected 
                                            ? const Color(0xFF1565C0)
                                            : Colors.black87,
                                        fontWeight: isSelected 
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Row(
            children: [
              if (_currentQuestion > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              
              if (_currentQuestion > 0) const SizedBox(width: 16),
              
              if (_currentQuestion < questions.length - 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answers.containsKey(_currentQuestion) ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answers.containsKey(_currentQuestion) ? _submitAssessment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit Assessment',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    if (_results == null) return const SizedBox.shrink();

    final score = _results!['score'] as int? ?? 0;
    final totalQuestions = _results!['totalQuestions'] as int? ?? 1;
    final percentage = _results!['percentage'] as double? ?? 0.0;
    final grade = _results!['grade'] as String? ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Assessment Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $score/$totalQuestions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}% • Grade: $grade',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _resetAssessment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Take New Assessment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
