import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';
import '../../services/api_service_complete.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  Map<String, dynamic>? _alumniStats;
  List<dynamic> _pendingRequests = [];
  List<dynamic> _upcomingEvents = [];
  Map<String, dynamic>? _alumniProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlumniData();
  }

  Future<void> _loadAlumniData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load alumni stats
      final stats = await AlumniAPI.getAlumniStats();
      
      // Load pending management requests
      final requests = await AlumniAPI.getPendingManagementRequests();
      
      // Load approved events
      final events = await EventsAPI.getApprovedEvents();
      
      // Load alumni profile
      final profile = await AlumniAPI.getMyProfile();
      
      setState(() {
        _alumniStats = stats;
        _pendingRequests = requests;
        _upcomingEvents = events.take(3).toList();
        _alumniProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading alumni data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Dashboard'),
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
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadAlumniData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Welcome Card
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'A',
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
                                  authProvider.user?.name ?? 'Alumni',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (authProvider.user?.department != null)
                                  Text(
                                    'Alumni - ${authProvider.user!.department}',
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
              ),
              const SizedBox(height: 24),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event,
                              size: 32,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_alumniStats?['eventsHosted'] ?? 0}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'Events Hosted',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 32,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_alumniStats?['totalConnections'] ?? 0}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'Connections',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              size: 32,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_pendingRequests.length}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            Text(
                              'Pending',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Main Features
              Text(
                'Alumni Services',
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
                    title: 'Event Requests',
                    subtitle: '${_pendingRequests.length} pending',
                    icon: Icons.event_note,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/alumni-event-requests');
                    },
                  ),
                  DashboardCard(
                    title: 'Network',
                    subtitle: 'Connect with alumni',
                    icon: Icons.network_check,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/alumni-directory');
                    },
                  ),
                  DashboardCard(
                    title: 'Events',
                    subtitle: 'View & manage events',
                    icon: Icons.event,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/events');
                    },
                  ),
                  DashboardCard(
                    title: 'Connections',
                    subtitle: 'Manage connections',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/connections');
                    },
                  ),
                  DashboardCard(
                    title: 'Profile',
                    subtitle: 'Update your profile',
                    icon: Icons.person,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  DashboardCard(
                    title: 'Messages',
                    subtitle: 'Chat with students',
                    icon: Icons.message,
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(context, '/user-chat');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
