import 'package:flutter/material.dart';
import '../../models/user.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  // User Management
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  String _userSearchQuery = '';
  String _selectedRole = '';
  String _selectedStatus = '';

  // System Settings
  Map<String, dynamic> _systemSettings = {};
  
  // Audit Logs
  List<Map<String, dynamic>> _auditLogs = [];

  // Reports
  Map<String, dynamic> _systemReports = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Load sample users
      _allUsers = [
        User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'STUDENT',
          verified: true,
          phoneNumber: '+1234567890',
          department: 'Computer Science',
          className: 'CS-2024',
        ),
        User(
          id: '2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'PROFESSOR',
          verified: true,
          phoneNumber: '+1234567891',
          department: 'Computer Science',
        ),
        User(
          id: '3',
          name: 'Mike Johnson',
          email: 'mike@example.com',
          role: 'ALUMNI',
          verified: false,
          phoneNumber: '+1234567892',
          department: 'Engineering',
          className: 'ENG-2020',
        ),
        User(
          id: '4',
          name: 'Sarah Wilson',
          email: 'sarah@example.com',
          role: 'MANAGEMENT',
          verified: true,
          phoneNumber: '+1234567893',
          department: 'Administration',
        ),
      ];

      _filteredUsers = List.from(_allUsers);

      // Load system settings
      _systemSettings = {
        'maintenanceMode': false,
        'allowRegistration': true,
        'requireEmailVerification': true,
        'maxFileUploadSize': 10, // MB
        'sessionTimeout': 30, // minutes
        'enableNotifications': true,
        'enableAnalytics': true,
        'backupFrequency': 'daily',
        'systemVersion': '1.0.0',
        'lastBackup': DateTime.now().subtract(const Duration(hours: 2)),
      };

      // Load audit logs
      _auditLogs = [
        {
          'id': '1',
          'action': 'User Login',
          'user': 'john@example.com',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'details': 'Successful login from mobile app',
          'ipAddress': '192.168.1.100',
        },
        {
          'id': '2',
          'action': 'User Created',
          'user': 'admin@example.com',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'details': 'New student user created: mike@example.com',
          'ipAddress': '192.168.1.101',
        },
        {
          'id': '3',
          'action': 'Settings Updated',
          'user': 'admin@example.com',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'details': 'System maintenance mode disabled',
          'ipAddress': '192.168.1.101',
        },
        {
          'id': '4',
          'action': 'Assessment Created',
          'user': 'jane@example.com',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'details': 'New assessment: Data Structures Quiz',
          'ipAddress': '192.168.1.102',
        },
      ];

      // Load system reports
      _systemReports = {
        'totalUsers': _allUsers.length,
        'activeUsers': _allUsers.where((u) => u.verified).length,
        'newUsersThisWeek': 12,
        'totalAssessments': 45,
        'assessmentsTakenToday': 8,
        'totalEvents': 15,
        'upcomingEvents': 5,
        'systemUptime': '99.9%',
        'storageUsed': '2.3 GB',
        'storageTotal': '10 GB',
      };

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesSearch = _userSearchQuery.isEmpty ||
            user.name.toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_userSearchQuery.toLowerCase());
        
        final matchesRole = _selectedRole.isEmpty || user.role == _selectedRole;
        
        final matchesStatus = _selectedStatus.isEmpty ||
            (_selectedStatus == 'verified' && user.verified) ||
            (_selectedStatus == 'unverified' && !user.verified);
        
        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  Future<void> _updateUserStatus(User user, bool verified) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        final index = _allUsers.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _allUsers[index] = User(
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            verified: verified,
            phoneNumber: user.phoneNumber,
            department: user.department,
            className: user.className,
          );
        }
      });
      
      _filterUsers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${verified ? 'verified' : 'unverified'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(User user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _allUsers.removeWhere((u) => u.id == user.id);
      });
      
      _filterUsers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateSystemSetting(String key, dynamic value) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _systemSettings[key] = value;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUserManagementTab() {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users by name or email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) {
                  _userSearchQuery = value;
                  _filterUsers();
                },
              ),
              const SizedBox(height: 12),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Roles'),
                      selected: _selectedRole.isEmpty,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = '';
                        });
                        _filterUsers();
                      },
                    ),
                    const SizedBox(width: 8),
                    ...['STUDENT', 'PROFESSOR', 'ALUMNI', 'MANAGEMENT'].map((role) =>
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(role),
                            selected: _selectedRole == role,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRole = selected ? role : '';
                              });
                              _filterUsers();
                            },
                          ),
                        )),
                    FilterChip(
                      label: const Text('Verified'),
                      selected: _selectedStatus == 'verified',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'verified' : '';
                        });
                        _filterUsers();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Unverified'),
                      selected: _selectedStatus == 'unverified',
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'unverified' : '';
                        });
                        _filterUsers();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Users list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (user.verified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(color: Colors.green, fontSize: 10),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Unverified',
                                style: TextStyle(color: Colors.orange, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'verify':
                          _updateUserStatus(user, true);
                          break;
                        case 'unverify':
                          _updateUserStatus(user, false);
                          break;
                        case 'edit':
                          _showEditUserDialog(user);
                          break;
                        case 'delete':
                          _showDeleteUserDialog(user);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!user.verified)
                        const PopupMenuItem(
                          value: 'verify',
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Verify User'),
                            ],
                          ),
                        ),
                      if (user.verified)
                        const PopupMenuItem(
                          value: 'unverify',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Unverify User'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit User'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete User'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Configuration',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Maintenance Mode
          Card(
            child: SwitchListTile(
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Temporarily disable system access'),
              value: _systemSettings['maintenanceMode'] ?? false,
              onChanged: (value) => _updateSystemSetting('maintenanceMode', value),
            ),
          ),
          
          // Registration
          Card(
            child: SwitchListTile(
              title: const Text('Allow Registration'),
              subtitle: const Text('Allow new users to register'),
              value: _systemSettings['allowRegistration'] ?? true,
              onChanged: (value) => _updateSystemSetting('allowRegistration', value),
            ),
          ),
          
          // Email Verification
          Card(
            child: SwitchListTile(
              title: const Text('Require Email Verification'),
              subtitle: const Text('New users must verify their email'),
              value: _systemSettings['requireEmailVerification'] ?? true,
              onChanged: (value) => _updateSystemSetting('requireEmailVerification', value),
            ),
          ),
          
          // Notifications
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Allow system to send notifications'),
              value: _systemSettings['enableNotifications'] ?? true,
              onChanged: (value) => _updateSystemSetting('enableNotifications', value),
            ),
          ),
          
          // Analytics
          Card(
            child: SwitchListTile(
              title: const Text('Enable Analytics'),
              subtitle: const Text('Collect usage analytics'),
              value: _systemSettings['enableAnalytics'] ?? true,
              onChanged: (value) => _updateSystemSetting('enableAnalytics', value),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Configuration Values
          Text(
            'Configuration Values',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: ListTile(
              title: const Text('Max File Upload Size'),
              subtitle: Text('${_systemSettings['maxFileUploadSize']} MB'),
              trailing: IconButton(
                onPressed: () => _showEditValueDialog('maxFileUploadSize', 'Max File Upload Size (MB)'),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              title: const Text('Session Timeout'),
              subtitle: Text('${_systemSettings['sessionTimeout']} minutes'),
              trailing: IconButton(
                onPressed: () => _showEditValueDialog('sessionTimeout', 'Session Timeout (minutes)'),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              title: const Text('Backup Frequency'),
              subtitle: Text(_systemSettings['backupFrequency']),
              trailing: IconButton(
                onPressed: () => _showBackupFrequencyDialog(),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Actions
          Text(
            'System Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Create System Backup'),
              subtitle: Text('Last backup: ${_formatDateTime(_systemSettings['lastBackup'])}'),
              trailing: ElevatedButton(
                onPressed: _createBackup,
                child: const Text('Backup Now'),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Clear System Cache'),
              subtitle: const Text('Clear all cached data'),
              trailing: ElevatedButton(
                onPressed: _clearCache,
                child: const Text('Clear Cache'),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export System Data'),
              subtitle: const Text('Download all system data'),
              trailing: ElevatedButton(
                onPressed: _exportData,
                child: const Text('Export'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'System Audit Logs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _auditLogs.length,
            itemBuilder: (context, index) {
              final log = _auditLogs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(log['action']),
                    child: Icon(
                      _getActionIcon(log['action']),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(log['action']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${log['user']}'),
                      Text('Details: ${log['details']}'),
                      Text(
                        'Time: ${_formatDateTime(log['timestamp'])}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Text(
                    log['ipAddress'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Reports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Users', _systemReports['totalUsers'].toString(), Icons.people, Colors.blue),
              _buildStatCard('Active Users', _systemReports['activeUsers'].toString(), Icons.people_alt, Colors.green),
              _buildStatCard('New Users (Week)', _systemReports['newUsersThisWeek'].toString(), Icons.person_add, Colors.orange),
              _buildStatCard('Total Assessments', _systemReports['totalAssessments'].toString(), Icons.quiz, Colors.purple),
              _buildStatCard('Assessments Today', _systemReports['assessmentsTakenToday'].toString(), Icons.today, Colors.red),
              _buildStatCard('Total Events', _systemReports['totalEvents'].toString(), Icons.event, Colors.teal),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // System Health
          Text(
            'System Health',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHealthRow('System Uptime', _systemReports['systemUptime'], Icons.timer, Colors.green),
                  _buildHealthRow('Storage Used', '${_systemReports['storageUsed']} / ${_systemReports['storageTotal']}', Icons.storage, Colors.blue),
                  _buildHealthRow('System Version', _systemSettings['systemVersion'], Icons.info, Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Export Options
          Text(
            'Export Reports',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('User Report'),
                  subtitle: const Text('Export all user data and statistics'),
                  trailing: ElevatedButton(
                    onPressed: () => _exportReport('users'),
                    child: const Text('Export'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Analytics Report'),
                  subtitle: const Text('Export system usage analytics'),
                  trailing: ElevatedButton(
                    onPressed: () => _exportReport('analytics'),
                    child: const Text('Export'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security Report'),
                  subtitle: const Text('Export security and audit logs'),
                  trailing: ElevatedButton(
                    onPressed: () => _exportReport('security'),
                    child: const Text('Export'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildHealthRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'user login':
        return Colors.green;
      case 'user created':
        return Colors.blue;
      case 'settings updated':
        return Colors.orange;
      case 'assessment created':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'user login':
        return Icons.login;
      case 'user created':
        return Icons.person_add;
      case 'settings updated':
        return Icons.settings;
      case 'assessment created':
        return Icons.quiz;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEditUserDialog(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user feature coming soon!')),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditValueDialog(String key, String label) {
    final controller = TextEditingController(text: _systemSettings[key].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                _updateSystemSetting(key, value);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBackupFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['daily', 'weekly', 'monthly'].map((frequency) => 
            RadioListTile<String>(
              title: Text(frequency.toUpperCase()),
              value: frequency,
              groupValue: _systemSettings['backupFrequency'],
              onChanged: (value) {
                if (value != null) {
                  _updateSystemSetting('backupFrequency', value);
                  Navigator.pop(context);
                }
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('System backup started...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('System cache cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export started...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportReport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.toUpperCase()} report export started...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Settings'),
            Tab(text: 'Audit Logs'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserManagementTab(),
                _buildSystemSettingsTab(),
                _buildAuditLogsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }
}
