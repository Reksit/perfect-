import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/feature_providers.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_extensions.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? _studentProfile;
  List<dynamic> _recentAssessments = [];
  List<dynamic> _upcomingEvents = [];
  List<dynamic> _recentTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load assessments
      await context.read<AssessmentProvider>().loadStudentAssessments();
      
      // Load events
      await context.read<EventsProvider>().loadApprovedEvents();
      
      // Load tasks
      await context.read<TaskProvider>().loadTasks();
      
      // Load student profile
      final profile = await StudentAPI.getMyProfile();
      
      setState(() {
        _studentProfile = profile;
        _recentAssessments = context.read<AssessmentProvider>().studentAssessments.take(3).toList();
        _upcomingEvents = context.read<EventsProvider>().approvedEvents.take(3).toList();
        _recentTasks = context.read<TaskProvider>().tasks.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                
                // Quick Stats
                _buildQuickStats(),
                const SizedBox(height: 24),
                
                // Main Features
                _buildQuickActions(),
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'S',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        authProvider.user?.name ?? 'Student',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authProvider.user?.className != null)
                        Text(
                          'Class: ${authProvider.user!.className}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      if (_studentProfile?['department'] != null)
                        Text(
                          'Department: ${_studentProfile!['department']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    final assessmentCount = context.read<AssessmentProvider>().studentAssessments.length;
    final taskCount = context.read<TaskProvider>().tasks.length;
    final completedTasks = context.read<TaskProvider>().tasks.where((task) => task['status'] == 'completed').length;
    final completionRate = taskCount > 0 ? (completedTasks / taskCount * 100).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Assessments',
            assessmentCount.toString(),
            Icons.assignment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tasks',
            taskCount.toString(),
            Icons.task_alt,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completion',
            '$completionRate%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardCard(
              title: 'Take Assessment',
              subtitle: 'AI-powered assessments',
              icon: Icons.quiz,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/ai-assessment');
              },
            ),
            DashboardCard(
              title: 'My Results',
              subtitle: 'View assessment scores',
              icon: Icons.analytics,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            DashboardCard(
              title: 'Alumni Network',
              subtitle: 'Connect with alumni',
              icon: Icons.people,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/alumni-directory');
              },
            ),
            DashboardCard(
              title: 'AI Chat',
              subtitle: 'Get help & guidance',
              icon: Icons.smart_toy,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/ai-chat');
              },
            ),
            DashboardCard(
              title: 'Study Tasks',
              subtitle: 'Manage your tasks',
              icon: Icons.task_alt,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/tasks');
              },
            ),
            DashboardCard(
              title: 'Events',
              subtitle: 'Campus events',
              icon: Icons.event,
              color: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/events');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Recent Assessments
        if (_recentAssessments.isNotEmpty) ...[
          _buildSectionCard(
            'Recent Assessments',
            Icons.assignment,
            Colors.blue,
            _recentAssessments.map((assessment) => ListTile(
              leading: Icon(Icons.quiz, color: Colors.blue),
              title: Text(assessment['title'] ?? 'Assessment'),
              subtitle: Text(assessment['domain'] ?? 'General'),
              trailing: assessment['score'] != null 
                ? Chip(
                    label: Text('${assessment['score']}%'),
                    backgroundColor: Colors.green.withOpacity(0.2),
                  )
                : Icon(Icons.pending, color: Colors.orange),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Recent Tasks
        if (_recentTasks.isNotEmpty) ...[
          _buildSectionCard(
            'Recent Tasks',
            Icons.task_alt,
            Colors.teal,
            _recentTasks.map((task) => ListTile(
              leading: Icon(
                task['status'] == 'completed' ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task['status'] == 'completed' ? Colors.green : Colors.grey,
              ),
              title: Text(task['title'] ?? 'Task'),
              subtitle: Text(task['description'] ?? ''),
              trailing: Text(
                task['status'] ?? 'pending',
                style: TextStyle(
                  color: task['status'] == 'completed' ? Colors.green : Colors.orange,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Upcoming Events
        if (_upcomingEvents.isNotEmpty) ...[
          _buildSectionCard(
            'Upcoming Events',
            Icons.event,
            Colors.red,
            _upcomingEvents.map((event) => ListTile(
              leading: Icon(Icons.event, color: Colors.red),
              title: Text(event['title'] ?? 'Event'),
              subtitle: Text(event['description'] ?? ''),
              trailing: Text(
                event['date'] ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Color color, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }
}
