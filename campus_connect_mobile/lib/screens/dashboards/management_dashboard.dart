import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service_complete.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  Map<String, dynamic>? _dashboardStats;
  List<dynamic> _alumniApplications = [];
  List<dynamic> _eventRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadManagementData();
  }

  Future<void> _loadManagementData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load management dashboard stats
      final stats = await ManagementAPI.getDashboardStats();
      
      // Load alumni applications
      final applications = await ManagementAPI.getAlumniApplications();
      
      // Load alumni event requests
      final requests = await ManagementAPI.getAllAlumniEventRequests();
      
      setState(() {
        _dashboardStats = stats;
        _alumniApplications = applications;
        _eventRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading management data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Dashboard'),
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
        onRefresh: _loadManagementData,
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
                _buildManagementActions(),
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
                    authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'M',
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
                        'Management Portal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        authProvider.user?.name ?? 'Administrator',
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Students',
            '${_dashboardStats?['totalStudents'] ?? 0}',
            Icons.school,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Alumni Apps',
            '${_alumniApplications.length}',
            Icons.people,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Event Requests',
            '${_eventRequests.length}',
            Icons.event,
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

  Widget _buildManagementActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Actions',
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
              title: 'Alumni Management',
              subtitle: '${_alumniApplications.length} pending',
              icon: Icons.approval,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/alumni-management');
              },
            ),
            DashboardCard(
              title: 'Student Analytics',
              subtitle: 'View performance',
              icon: Icons.analytics,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/student-analytics');
              },
            ),
            DashboardCard(
              title: 'Event Approval',
              subtitle: '${_eventRequests.length} requests',
              icon: Icons.event_available,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/event-approval');
              },
            ),
            DashboardCard(
              title: 'Resume Analysis',
              subtitle: 'ATS reports',
              icon: Icons.description,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/resume-analysis');
              },
            ),
            DashboardCard(
              title: 'AI Student Search',
              subtitle: 'Find by skills',
              icon: Icons.search,
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/ai-student-search');
              },
            ),
            DashboardCard(
              title: 'System Reports',
              subtitle: 'Performance metrics',
              icon: Icons.assessment,
              color: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/system-reports');
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
        
        // Recent Alumni Applications
        if (_alumniApplications.isNotEmpty) ...[
          _buildSectionCard(
            'Recent Alumni Applications',
            Icons.people,
            Colors.blue,
            _alumniApplications.take(3).map((application) => ListTile(
              leading: Icon(Icons.person_add, color: Colors.blue),
              title: Text(application['name'] ?? 'Alumni Application'),
              subtitle: Text(application['email'] ?? ''),
              trailing: Chip(
                label: Text(application['status'] ?? 'pending'),
                backgroundColor: application['status'] == 'approved' 
                  ? Colors.green.withOpacity(0.2) 
                  : Colors.orange.withOpacity(0.2),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Recent Event Requests
        if (_eventRequests.isNotEmpty) ...[
          _buildSectionCard(
            'Recent Event Requests',
            Icons.event,
            Colors.orange,
            _eventRequests.take(3).map((request) => ListTile(
              leading: Icon(Icons.event_note, color: Colors.orange),
              title: Text(request['title'] ?? 'Event Request'),
              subtitle: Text(request['description'] ?? ''),
              trailing: Text(
                request['status'] ?? 'pending',
                style: TextStyle(
                  color: request['status'] == 'approved' ? Colors.green : Colors.orange,
                ),
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