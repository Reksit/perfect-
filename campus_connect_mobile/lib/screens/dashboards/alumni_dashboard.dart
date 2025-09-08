import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
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
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
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
                              '3',
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
                              '45',
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
                    subtitle: 'Manage event requests',
                    icon: Icons.event_note,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigate to event requests
                    },
                  ),
                  DashboardCard(
                    title: 'Network',
                    subtitle: 'Connect with alumni',
                    icon: Icons.network_check,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navigate to alumni network
                    },
                  ),
                  DashboardCard(
                    title: 'Mentorship',
                    subtitle: 'Guide students',
                    icon: Icons.school,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navigate to mentorship
                    },
                  ),
                  DashboardCard(
                    title: 'Job Board',
                    subtitle: 'Share opportunities',
                    icon: Icons.work,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Navigate to job board
                    },
                  ),
                  DashboardCard(
                    title: 'Profile',
                    subtitle: 'Update your profile',
                    icon: Icons.person,
                    color: Colors.teal,
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                  DashboardCard(
                    title: 'Messages',
                    subtitle: 'Chat with students',
                    icon: Icons.message,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Navigate to messages
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
