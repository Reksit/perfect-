import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return UserAccountsDrawerHeader(
                accountName: Text(authProvider.user?.name ?? 'User'),
                accountEmail: Text(authProvider.user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.user?.isStudent == true) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.quiz),
                            title: const Text('Assessments'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to assessments
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.analytics),
                            title: const Text('My Results'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to results
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.people),
                            title: const Text('Alumni Network'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to alumni directory
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.smart_toy),
                            title: const Text('AI Chat'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to AI chat
                            },
                          ),
                        ],
                      );
                    } else if (authProvider.user?.isProfessor == true) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add_task),
                            title: const Text('Create Assessment'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to create assessment
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.analytics),
                            title: const Text('Student Analytics'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to analytics
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.class_),
                            title: const Text('Class Management'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to class management
                            },
                          ),
                        ],
                      );
                    } else if (authProvider.user?.isAlumni == true) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.event_note),
                            title: const Text('Event Requests'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to event requests
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.network_check),
                            title: const Text('Alumni Network'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to network
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.work),
                            title: const Text('Job Board'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to job board
                            },
                          ),
                        ],
                      );
                    } else if (authProvider.user?.isManagement == true) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('User Management'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to user management
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.verified_user),
                            title: const Text('Alumni Approval'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to alumni approval
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.analytics),
                            title: const Text('System Analytics'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to analytics
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.profile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.notifications);
                  },
                ),
                
                // Theme Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      title: Text(
                        themeProvider.themeMode == ThemeMode.dark
                            ? 'Light Mode'
                            : 'Dark Mode',
                      ),
                      onTap: () {
                        themeProvider.setThemeMode(
                          themeProvider.themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Logout
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login,
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
