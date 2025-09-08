import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feature_providers.dart';
import '../../providers/app_providers.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load professor profile and dashboard data
      final professorProvider = context.read<ProfessorProvider>();
      await professorProvider.loadProfessorProfile();
      await professorProvider.loadProfessorCourses();
      await professorProvider.loadStudentAnalytics();
      
      // Load assessments data
      final assessmentProvider = context.read<AssessmentProvider>();
      await assessmentProvider.loadProfessorAssessments();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
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
            : _error != null
                ? _buildErrorState()
                : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildTeachingTools(),
          const SizedBox(height: 24),
          _buildUpcomingClasses(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: authProvider.user?.profileImage != null
                      ? NetworkImage(authProvider.user!.profileImage!)
                      : null,
                  child: authProvider.user?.profileImage == null
                      ? Text(
                          authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'P',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
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
                        'Prof. ${authProvider.user?.name ?? 'Professor'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authProvider.user?.department != null)
                        Text(
                          'Department: ${authProvider.user!.department}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    return Consumer<ProfessorProvider>(
      builder: (context, professorProvider, child) {
        return Consumer<AssessmentProvider>(
          builder: (context, assessmentProvider, child) {
            final courseCount = professorProvider.courses.length;
            final studentCount = professorProvider.totalStudents;
            final assessmentCount = assessmentProvider.professorAssessments.length;
            final pendingGrading = assessmentProvider.pendingGradingCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Courses',
                        courseCount.toString(),
                        Icons.school,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Students',
                        studentCount.toString(),
                        Icons.people,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Assessments',
                        assessmentCount.toString(),
                        Icons.assignment,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending Grading',
                        pendingGrading.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color[700]),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color[700],
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

  Widget _buildRecentActivity() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final recentAssessments = provider.professorAssessments.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Assessments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/assessments');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentAssessments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No assessments created yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: recentAssessments.map((assessment) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.assignment, color: Colors.white),
                      ),
                      title: Text(assessment['title'] ?? 'Assessment'),
                      subtitle: Text(
                        '${assessment['course'] ?? 'Course'} • ${assessment['submissions']?.length ?? 0} submissions',
                      ),
                      trailing: Chip(
                        label: Text(
                          assessment['status'] ?? 'Active',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(assessment['status']),
                      ),
                      onTap: () {
                        // Navigate to assessment details
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green.withOpacity(0.2);
      case 'draft':
        return Colors.orange.withOpacity(0.2);
      case 'completed':
        return Colors.blue.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Widget _buildTeachingTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teaching Tools',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              title: 'Create Assessment',
              subtitle: 'AI-powered or manual',
              icon: Icons.add_task,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/ai-assessment');
              },
            ),
            DashboardCard(
              title: 'View Results',
              subtitle: 'Student performance',
              icon: Icons.analytics,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/assessment-results');
              },
            ),
            DashboardCard(
              title: 'Student Analytics',
              subtitle: 'Performance insights',
              icon: Icons.insights,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/student-analytics');
              },
            ),
            DashboardCard(
              title: 'Alumni Directory',
              subtitle: 'Connect alumni',
              icon: Icons.contacts,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/alumni-directory');
              },
            ),
            DashboardCard(
              title: 'Chat Support',
              subtitle: 'Help students',
              icon: Icons.chat,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            DashboardCard(
              title: 'Class Management',
              subtitle: 'Manage classes',
              icon: Icons.class_,
              color: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/class-management');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingClasses() {
    return Consumer<ProfessorProvider>(
      builder: (context, provider, child) {
        final upcomingClasses = provider.upcomingClasses.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Classes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/schedule');
                  },
                  child: const Text('View Schedule'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (upcomingClasses.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No upcoming classes today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: upcomingClasses.map((classItem) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: const Icon(Icons.schedule, color: Colors.white),
                      ),
                      title: Text(classItem['courseName'] ?? 'Class'),
                      subtitle: Text(
                        '${classItem['room'] ?? 'Room TBD'} • ${classItem['time'] ?? 'Time TBD'}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            classItem['duration'] ?? '1h',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${classItem['studentCount'] ?? 0} students',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to class details
                      },
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
