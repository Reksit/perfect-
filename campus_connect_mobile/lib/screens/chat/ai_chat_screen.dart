import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/api_extensions.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: "Hello! I'm your AI Career Assistant. I can help you with:\n\n"
              "• Career guidance and planning\n"
              "• Resume and interview tips\n"
              "• Industry insights\n"
              "• Skills development recommendations\n"
              "• Job search strategies\n\n"
              "What would you like to know about your career?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Generate AI response based on user message
      final aiResponse = await _generateAIResponse(userMessage);
      
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            message: "I apologize, but I'm having trouble responding right now. Please try again later.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _generateAIResponse(String userMessage) async {
    try {
      final response = await ChatAPI.sendAIMessage(userMessage);
      return response['message'] ?? 'I apologize, but I couldn\'t generate a response right now.';
    } catch (e) {
      print('Error getting AI response: $e');
      // Fallback to local responses
      return _getFallbackResponse(userMessage);
    }
  }

  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Career guidance responses
    if (message.contains('career') || message.contains('job') || message.contains('work')) {
      return _getCareerGuidance(message);
    }
    // Resume and interview tips
    else if (message.contains('resume') || message.contains('cv') || message.contains('interview')) {
      return _getResumeInterviewTips(message);
    }
    // Skills development
    else if (message.contains('skill') || message.contains('learn') || message.contains('development')) {
      return _getSkillsDevelopmentAdvice(message);
    }
    // Industry insights
    else if (message.contains('industry') || message.contains('market') || message.contains('trend')) {
      return _getIndustryInsights(message);
    }
    // General career advice
    else {
      return _getGeneralCareerAdvice();
    }
  }

  String _getCareerGuidance(String message) {
    if (message.contains('change') || message.contains('switch')) {
      return "Career transitions can be exciting! Here's my advice:\n\n"
          "• Assess your transferable skills\n"
          "• Research your target industry thoroughly\n"
          "• Network with professionals in your desired field\n"
          "• Consider gaining relevant certifications\n"
          "• Start with informational interviews\n"
          "• Update your LinkedIn profile\n\n"
          "What specific career change are you considering?";
    } else if (message.contains('path') || message.contains('planning')) {
      return "Career planning is crucial for long-term success:\n\n"
          "• Set SMART career goals (Specific, Measurable, Achievable, Relevant, Time-bound)\n"
          "• Identify skills gaps and create learning plans\n"
          "• Build a professional network\n"
          "• Seek mentorship opportunities\n"
          "• Regularly review and adjust your plans\n\n"
          "What's your current career stage and goals?";
    } else {
      return "Here are some general career guidance tips:\n\n"
          "• Focus on continuous learning and skill development\n"
          "• Build strong professional relationships\n"
          "• Stay updated with industry trends\n"
          "• Seek feedback regularly\n"
          "• Take on challenging projects\n"
          "• Maintain work-life balance\n\n"
          "Is there a specific area of your career you'd like to discuss?";
    }
  }

  String _getResumeInterviewTips(String message) {
    if (message.contains('resume') || message.contains('cv')) {
      return "Here are my top resume tips:\n\n"
          "• Tailor your resume for each job application\n"
          "• Use strong action verbs and quantify achievements\n"
          "• Keep it concise (1-2 pages max)\n"
          "• Include relevant keywords from job descriptions\n"
          "• Proofread carefully for errors\n"
          "• Use a clean, professional format\n\n"
          "Would you like specific advice for any section of your resume?";
    } else {
      return "Interview preparation is key to success:\n\n"
          "• Research the company and role thoroughly\n"
          "• Prepare STAR method examples (Situation, Task, Action, Result)\n"
          "• Practice common interview questions\n"
          "• Prepare thoughtful questions to ask the interviewer\n"
          "• Dress professionally and arrive early\n"
          "• Follow up with a thank-you email\n\n"
          "What type of interview are you preparing for?";
    }
  }

  String _getSkillsDevelopmentAdvice(String message) {
    return "Skills development is essential in today's job market:\n\n"
        "• Identify in-demand skills in your field\n"
        "• Use online learning platforms (Coursera, LinkedIn Learning, Udemy)\n"
        "• Attend workshops and conferences\n"
        "• Join professional associations\n"
        "• Find a mentor in your field\n"
        "• Practice new skills on real projects\n"
        "• Get certifications where relevant\n\n"
        "What specific skills are you looking to develop?";
  }

  String _getIndustryInsights(String message) {
    return "Staying informed about industry trends is crucial:\n\n"
        "• Follow industry publications and blogs\n"
        "• Join professional social media groups\n"
        "• Attend virtual and in-person networking events\n"
        "• Subscribe to industry newsletters\n"
        "• Follow thought leaders on LinkedIn\n"
        "• Participate in industry forums and discussions\n\n"
        "Which industry are you most interested in learning about?";
  }

  String _getGeneralCareerAdvice() {
    return "Here's some general career wisdom:\n\n"
        "• Your career is a marathon, not a sprint\n"
        "• Invest in relationships, not just skills\n"
        "• Embrace challenges as growth opportunities\n"
        "• Stay curious and keep learning\n"
        "• Be authentic and true to your values\n"
        "• Take calculated risks\n"
        "• Celebrate your achievements\n\n"
        "What specific career topic would you like to explore further?";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Career Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildLoadingMessage();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.smart_toy,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.smart_toy,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me about your career...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
