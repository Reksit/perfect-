import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;
  bool _isEditing = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  
  // Profile data
  Map<String, dynamic> _profileData = {};
  List<String> _skills = [];
  List<String> _interests = [];
  List<Map<String, dynamic>> _education = [];
  List<Map<String, dynamic>> _experience = [];
  List<Map<String, dynamic>> _achievements = [];

  // Privacy settings
  final Map<String, bool> _privacySettings = {
    'showEmail': true,
    'showPhone': false,
    'showLocation': true,
    'showEducation': true,
    'showExperience': true,
    'showSkills': true,
    'showSocialLinks': true,
    'allowDirectMessages': true,
    'allowConnectionRequests': true,
    'showOnlineStatus': true,
  };

  // Notification preferences
  final Map<String, bool> _notificationSettings = {
    'emailNotifications': true,
    'pushNotifications': true,
    'assessmentReminders': true,
    'eventNotifications': true,
    'connectionRequests': true,
    'jobAlerts': true,
    'weeklyDigest': true,
    'marketingEmails': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Load comprehensive profile data
      _profileData = {
        'bio': 'Passionate software developer with experience in Flutter and web technologies. Always eager to learn new technologies and contribute to meaningful projects.',
        'location': 'San Francisco, CA',
        'website': 'https://johndoe.dev',
        'linkedin': 'https://linkedin.com/in/johndoe',
        'github': 'https://github.com/johndoe',
        'profileViews': 156,
        'connectionCount': 45,
        'joinDate': DateTime(2023, 9, 1),
      };

      _skills = [
        'Flutter', 'Dart', 'React', 'JavaScript', 'Python', 'Java',
        'Firebase', 'REST APIs', 'Git', 'Agile Development'
      ];

      _interests = [
        'Mobile Development', 'AI/ML', 'Open Source', 'Startup Ecosystem',
        'Tech Innovation', 'Software Architecture'
      ];

      _education = [
        {
          'institution': 'University of Technology',
          'degree': 'Bachelor of Computer Science',
          'field': 'Software Engineering',
          'startYear': 2020,
          'endYear': 2024,
          'gpa': '3.8/4.0',
          'description': 'Specialized in software engineering with focus on mobile application development.',
        }
      ];

      _experience = [
        {
          'company': 'Tech Solutions Inc.',
          'position': 'Software Developer Intern',
          'startDate': 'June 2023',
          'endDate': 'August 2023',
          'description': 'Developed mobile applications using Flutter and integrated with REST APIs. Collaborated with cross-functional teams in an Agile environment.',
          'skills': ['Flutter', 'Dart', 'REST APIs', 'Firebase']
        }
      ];

      _achievements = [
        {
          'title': 'Dean\'s List',
          'description': 'Achieved Dean\'s List for academic excellence (GPA > 3.5)',
          'date': 'Spring 2023',
          'type': 'Academic'
        },
        {
          'title': 'Best Mobile App - Hackathon 2023',
          'description': 'Won first place for developing an innovative education app',
          'date': 'October 2023',
          'type': 'Competition'
        }
      ];

      // Initialize controllers
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = _profileData['bio'] ?? '';
      _locationController.text = _profileData['location'] ?? '';
      _websiteController.text = _profileData['website'] ?? '';
      _linkedinController.text = _profileData['linkedin'] ?? '';
      _githubController.text = _profileData['github'] ?? '';

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Update profile data
      _profileData.addAll({
        'bio': _bioController.text,
        'location': _locationController.text,
        'website': _websiteController.text,
        'linkedin': _linkedinController.text,
        'github': _githubController.text,
      });

      setState(() {
        _loading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBasicInfoTab() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.substring(0, 2).toUpperCase() ?? 'US',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image picker coming soon!')),
                              );
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.role?.replaceAll('_', ' ') ?? 'Role',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (user?.verified == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Basic Information Form
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField('Full Name', _nameController, Icons.person, enabled: _isEditing),
          _buildTextField('Email', _emailController, Icons.email, enabled: false),
          _buildTextField('Phone Number', _phoneController, Icons.phone, enabled: _isEditing),
          _buildTextField('Location', _locationController, Icons.location_on, enabled: _isEditing),
          _buildTextField('Bio', _bioController, Icons.info, maxLines: 3, enabled: _isEditing),
          
          const SizedBox(height: 24),
          
          // Social Links
          Text(
            'Social Links',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTextField('Website', _websiteController, Icons.language, enabled: _isEditing),
          _buildTextField('LinkedIn', _linkedinController, Icons.work, enabled: _isEditing),
          _buildTextField('GitHub', _githubController, Icons.code, enabled: _isEditing),

          if (_isEditing) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                      _loadProfileData(); // Reset form
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _loading ? null : _saveProfile,
                    isLoading: _loading,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsAndInterestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skills',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showAddSkillDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_skills.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('No skills added yet. Tap + to add skills.'),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) => Chip(
                label: Text(skill),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _skills.remove(skill);
                  });
                },
              )).toList(),
            ),
          
          const SizedBox(height: 32),
          
          // Interests Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showAddInterestDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_interests.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('No interests added yet. Tap + to add interests.'),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.map((interest) => Chip(
                label: Text(interest),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _interests.remove(interest);
                  });
                },
              )).toList(),
            ),

          const SizedBox(height: 32),

          // Education Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Education',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showAddEducationDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._education.map((edu) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              edu['degree'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _education.remove(edu);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      Text(
                        edu['institution'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${edu['startYear']} - ${edu['endYear']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (edu['gpa'] != null)
                        Text(
                          'GPA: ${edu['gpa']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (edu['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(edu['description']),
                      ],
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 32),

          // Experience Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _showAddExperienceDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._experience.map((exp) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exp['position'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _experience.remove(exp);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      Text(
                        exp['company'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${exp['startDate']} - ${exp['endDate']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (exp['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(exp['description']),
                      ],
                      if (exp['skills'] != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: (exp['skills'] as List<String>).map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control what information is visible to other users',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          ..._privacySettings.entries.map((entry) => _buildPrivacySetting(
                _getPrivacyLabel(entry.key),
                _getPrivacyDescription(entry.key),
                entry.value,
                (value) {
                  setState(() {
                    _privacySettings[entry.key] = value;
                  });
                },
              )),
          
          const SizedBox(height: 32),
          
          // Account Actions
          Text(
            'Account Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildActionButton(
            'Change Password',
            'Update your account password',
            Icons.lock,
            () => _showChangePasswordDialog(),
          ),
          
          _buildActionButton(
            'Download Data',
            'Download a copy of your data',
            Icons.download,
            () => _downloadData(),
          ),
          
          _buildActionButton(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever,
            () => _showDeleteAccountDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what notifications you want to receive',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          ..._notificationSettings.entries.map((entry) => _buildNotificationSetting(
                _getNotificationLabel(entry.key),
                _getNotificationDescription(entry.key),
                entry.value,
                (value) {
                  setState(() {
                    _notificationSettings[entry.key] = value;
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySetting(String title, String description, bool value, Function(bool) onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNotificationSetting(String title, String description, bool value, Function(bool) onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionButton(String title, String description, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : null),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : null),
        ),
        subtitle: Text(description),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  String _getPrivacyLabel(String key) {
    switch (key) {
      case 'showEmail': return 'Show Email Address';
      case 'showPhone': return 'Show Phone Number';
      case 'showLocation': return 'Show Location';
      case 'showEducation': return 'Show Education';
      case 'showExperience': return 'Show Experience';
      case 'showSkills': return 'Show Skills';
      case 'showSocialLinks': return 'Show Social Links';
      case 'allowDirectMessages': return 'Allow Direct Messages';
      case 'allowConnectionRequests': return 'Allow Connection Requests';
      case 'showOnlineStatus': return 'Show Online Status';
      default: return key;
    }
  }

  String _getPrivacyDescription(String key) {
    switch (key) {
      case 'showEmail': return 'Other users can see your email address';
      case 'showPhone': return 'Other users can see your phone number';
      case 'showLocation': return 'Other users can see your location';
      case 'showEducation': return 'Other users can see your education history';
      case 'showExperience': return 'Other users can see your work experience';
      case 'showSkills': return 'Other users can see your skills';
      case 'showSocialLinks': return 'Other users can see your social media links';
      case 'allowDirectMessages': return 'Other users can send you direct messages';
      case 'allowConnectionRequests': return 'Other users can send you connection requests';
      case 'showOnlineStatus': return 'Other users can see when you\'re online';
      default: return '';
    }
  }

  String _getNotificationLabel(String key) {
    switch (key) {
      case 'emailNotifications': return 'Email Notifications';
      case 'pushNotifications': return 'Push Notifications';
      case 'assessmentReminders': return 'Assessment Reminders';
      case 'eventNotifications': return 'Event Notifications';
      case 'connectionRequests': return 'Connection Requests';
      case 'jobAlerts': return 'Job Alerts';
      case 'weeklyDigest': return 'Weekly Digest';
      case 'marketingEmails': return 'Marketing Emails';
      default: return key;
    }
  }

  String _getNotificationDescription(String key) {
    switch (key) {
      case 'emailNotifications': return 'Receive notifications via email';
      case 'pushNotifications': return 'Receive push notifications on your device';
      case 'assessmentReminders': return 'Get reminded about upcoming assessments';
      case 'eventNotifications': return 'Get notified about events and activities';
      case 'connectionRequests': return 'Get notified when someone wants to connect';
      case 'jobAlerts': return 'Get notified about relevant job opportunities';
      case 'weeklyDigest': return 'Receive a weekly summary of activity';
      case 'marketingEmails': return 'Receive promotional emails and updates';
      default: return '';
    }
  }

  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter skill name',
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  _skills.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter interest',
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  _interests.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddEducationDialog() {
    // TODO: Implement comprehensive education form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Education form coming soon!')),
    );
  }

  void _showAddExperienceDialog() {
    // TODO: Implement comprehensive experience form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Experience form coming soon!')),
    );
  }

  void _showChangePasswordDialog() {
    Navigator.pushNamed(context, '/password-change');
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data download started!')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Skills & Experience'),
            Tab(text: 'Privacy'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildSkillsAndInterestsTab(),
                _buildPrivacyTab(),
                _buildNotificationsTab(),
              ],
            ),
    );
  }
}
