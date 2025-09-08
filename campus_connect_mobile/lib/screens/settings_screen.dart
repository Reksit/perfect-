import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import 'profile_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _connectionRequests = true;
  bool _eventUpdates = true;
  bool _messageNotifications = true;
  bool _darkMode = false;
  String _language = 'English';
  String _privacyLevel = 'Public';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          _buildListTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileManagementScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            icon: Icons.security,
            title: 'Privacy Settings',
            subtitle: 'Manage your privacy preferences',
            onTap: () => _showPrivacySettings(),
          ),
          _buildListTile(
            icon: Icons.key,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordDialog(),
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Enable Notifications',
            subtitle: 'Receive app notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          if (_notificationsEnabled) ...[
            _buildSwitchTile(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.phone_android,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.people,
              title: 'Connection Requests',
              subtitle: 'Notify when someone wants to connect',
              value: _connectionRequests,
              onChanged: (value) {
                setState(() {
                  _connectionRequests = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.event,
              title: 'Event Updates',
              subtitle: 'Notify about event changes',
              value: _eventUpdates,
              onChanged: (value) {
                setState(() {
                  _eventUpdates = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.message,
              title: 'Messages',
              subtitle: 'Notify when you receive messages',
              value: _messageNotifications,
              onChanged: (value) {
                setState(() {
                  _messageNotifications = value;
                });
              },
            ),
          ],

          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // TODO: Implement theme switching
            },
          ),
          _buildListTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _language,
            onTap: () => _showLanguageSelector(),
          ),

          const Divider(),

          // Security Section
          _buildSectionHeader('Security'),
          _buildListTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face unlock',
            onTap: () => _showBiometricSettings(),
          ),
          _buildListTile(
            icon: Icons.shield,
            title: 'Two-Factor Authentication',
            subtitle: 'Add extra security to your account',
            onTap: () => _showTwoFactorSettings(),
          ),
          _buildListTile(
            icon: Icons.devices,
            title: 'Active Sessions',
            subtitle: 'Manage logged-in devices',
            onTap: () => _showActiveSessions(),
          ),

          const Divider(),

          // Support Section
          _buildSectionHeader('Support'),
          _buildListTile(
            icon: Icons.help,
            title: 'Help & FAQ',
            subtitle: 'Get help and find answers',
            onTap: () => _showHelp(),
          ),
          _buildListTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () => _showFeedbackDialog(),
          ),
          _buildListTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Let us know about issues',
            onTap: () => _showBugReportDialog(),
          ),
          _buildListTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(),
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Get a copy of your data',
            onTap: () => _downloadData(),
          ),
          _buildListTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: () => _showDeleteAccountDialog(),
            textColor: Colors.red,
          ),
          _buildListTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showSignOutDialog(),
            textColor: Colors.red,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Public'),
              subtitle: const Text('Everyone can see your profile'),
              leading: Radio<String>(
                value: 'Public',
                groupValue: _privacyLevel,
                onChanged: (value) {
                  setState(() {
                    _privacyLevel = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Connections Only'),
              subtitle: const Text('Only your connections can see your profile'),
              leading: Radio<String>(
                value: 'Connections',
                groupValue: _privacyLevel,
                onChanged: (value) {
                  setState(() {
                    _privacyLevel = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Private'),
              subtitle: const Text('Only you can see your profile'),
              leading: Radio<String>(
                value: 'Private',
                groupValue: _privacyLevel,
                onChanged: (value) {
                  setState(() {
                    _privacyLevel = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) => ListTile(
            title: Text(language),
            leading: Radio<String>(
              value: language,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showBiometricSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometric settings coming soon')),
    );
  }

  void _showTwoFactorSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon')),
    );
  }

  void _showActiveSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Active sessions management coming soon')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help section coming soon')),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your feedback...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final bugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: TextField(
          controller: bugController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Describe the bug...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report sent successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Connect',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, size: 48),
      children: [
        const Text('A comprehensive platform connecting students, alumni, and professors.'),
      ],
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'Your data will be prepared and sent to your registered email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data download request submitted')),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion not implemented yet')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
