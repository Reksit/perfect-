import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AnalyticsData {
  final String label;
  final double value;
  final Color color;

  AnalyticsData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ActivityData {
  final DateTime date;
  final int count;

  ActivityData({
    required this.date,
    required this.count,
  });
}

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _loading = true;
  String _selectedPeriod = '7days';
  
  // Sample data - replace with actual API calls
  Map<String, dynamic> _dashboardData = {};
  List<ActivityData> _activityData = [];
  List<AnalyticsData> _performanceData = [];
  List<AnalyticsData> _engagementData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _loading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate sample data based on selected period
      _generateSampleData();
      
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load analytics: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateSampleData() {
    // Dashboard overview data
    _dashboardData = {
      'totalUsers': 1247,
      'activeUsers': 892,
      'totalAssessments': 156,
      'completedAssessments': 134,
      'averageScore': 82.5,
      'totalEvents': 23,
      'upcomingEvents': 8,
      'connectionRequests': 45,
      'jobApplications': 78,
      'resumeDownloads': 234,
    };

    // Activity heatmap data
    _activityData = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      return ActivityData(
        date: date,
        count: (index * 2 + 5) % 15, // Random activity pattern
      );
    });

    // Performance distribution
    _performanceData = [
      AnalyticsData(label: 'Excellent (90-100)', value: 25, color: Colors.green),
      AnalyticsData(label: 'Good (80-89)', value: 35, color: Colors.blue),
      AnalyticsData(label: 'Average (70-79)', value: 25, color: Colors.orange),
      AnalyticsData(label: 'Below Average (<70)', value: 15, color: Colors.red),
    ];

    // Engagement metrics
    _engagementData = [
      AnalyticsData(label: 'Daily Active', value: 45, color: Colors.purple),
      AnalyticsData(label: 'Weekly Active', value: 30, color: Colors.indigo),
      AnalyticsData(label: 'Monthly Active', value: 20, color: Colors.teal),
      AnalyticsData(label: 'Inactive', value: 5, color: Colors.grey),
    ];
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeatmap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Activity Heatmap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Heatmap grid
            SizedBox(
              height: 120,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: _activityData.length,
                itemBuilder: (context, index) {
                  final activity = _activityData[index];
                  final intensity = activity.count / 15.0; // Normalize to 0-1
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: intensity * 0.8 + 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        activity.date.day.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: intensity > 0.5 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: (index + 1) * 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                Text(
                  'More',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, List<AnalyticsData> data, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Simple pie chart representation
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie chart placeholder (would use a chart library in real app)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: data.map((d) => d.color).toList(),
                          stops: _calculateStops(data),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '100%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Legend
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Text(
                                '${item.value.toInt()}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _calculateStops(List<AnalyticsData> data) {
    double total = data.fold(0, (sum, item) => sum + item.value);
    double currentStop = 0;
    List<double> stops = [];
    
    for (var item in data) {
      stops.add(currentStop);
      currentStop += item.value / total;
    }
    stops.add(1.0);
    
    return stops;
  }

  Widget _buildRecentActivities() {
    final activities = [
      {'type': 'assessment', 'description': '15 students completed Data Structures quiz', 'time': '2 hours ago'},
      {'type': 'event', 'description': 'Tech Career Fair scheduled for next week', 'time': '4 hours ago'},
      {'type': 'connection', 'description': '8 new alumni connection requests', 'time': '6 hours ago'},
      {'type': 'job', 'description': '3 new job postings from tech companies', 'time': '1 day ago'},
      {'type': 'resume', 'description': '25 resumes downloaded by recruiters', 'time': '1 day ago'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...activities.map((activity) {
              IconData activityIcon;
              Color activityColor;
              
              switch (activity['type']) {
                case 'assessment':
                  activityIcon = Icons.quiz;
                  activityColor = Colors.blue;
                  break;
                case 'event':
                  activityIcon = Icons.event;
                  activityColor = Colors.purple;
                  break;
                case 'connection':
                  activityIcon = Icons.people;
                  activityColor = Colors.green;
                  break;
                case 'job':
                  activityIcon = Icons.work;
                  activityColor = Colors.orange;
                  break;
                case 'resume':
                  activityIcon = Icons.description;
                  activityColor = Colors.red;
                  break;
                default:
                  activityIcon = Icons.info;
                  activityColor = Colors.grey;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(activityIcon, color: activityColor, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['description']!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity['time']!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadDashboardData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7days', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30days', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90days', child: Text('Last 3 months')),
              const PopupMenuItem(value: '1year', child: Text('Last year')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.date_range, color: Colors.white),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    Text(
                      'Analytics for ${_selectedPeriod == '7days' ? 'Last 7 days' : _selectedPeriod == '30days' ? 'Last 30 days' : _selectedPeriod == '90days' ? 'Last 3 months' : 'Last year'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Key metrics
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          'Total Users',
                          _dashboardData['totalUsers'].toString(),
                          '${_dashboardData['activeUsers']} active',
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Assessments',
                          _dashboardData['totalAssessments'].toString(),
                          '${_dashboardData['completedAssessments']} completed',
                          Icons.quiz,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Average Score',
                          '${_dashboardData['averageScore']}%',
                          'Across all assessments',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Events',
                          _dashboardData['totalEvents'].toString(),
                          '${_dashboardData['upcomingEvents']} upcoming',
                          Icons.event,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Activity heatmap
                    _buildActivityHeatmap(),
                    const SizedBox(height: 24),
                    
                    // Charts section
                    Row(
                      children: [
                        Expanded(
                          child: _buildPieChart(
                            'Performance Distribution',
                            _performanceData,
                            Icons.analytics,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPieChart(
                            'User Engagement',
                            _engagementData,
                            Icons.people_alt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Recent activities
                    _buildRecentActivities(),
                    
                    // Additional metrics for management users
                    if (user?.role == 'MANAGEMENT') ...[
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            'Connection Requests',
                            _dashboardData['connectionRequests'].toString(),
                            'Alumni networking',
                            Icons.connect_without_contact,
                            Colors.teal,
                          ),
                          _buildStatCard(
                            'Job Applications',
                            _dashboardData['jobApplications'].toString(),
                            'Through platform',
                            Icons.work,
                            Colors.indigo,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
