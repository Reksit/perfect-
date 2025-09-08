import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/api_extensions.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/loading_widget.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profileData;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  // Student-specific controllers
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _gpaController = TextEditingController();
  
  // Alumni-specific controllers
  final _graduationYearController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _experienceController = TextEditingController();
  
  // Professor-specific controllers
  final _titleController = TextEditingController();
  final _officeController = TextEditingController();
  final _researchAreasController = TextEditingController();
  final _qualificationsController = TextEditingController();

  List<String> _skills = [];
  List<String> _interests = [];
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _gpaController.dispose();
    _graduationYearController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _experienceController.dispose();
    _titleController.dispose();
    _officeController.dispose();
    _researchAreasController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _userRole = authProvider.userRole;
      
      Map<String, dynamic> profile;
      switch (_userRole) {
        case 'student':
          profile = await StudentAPI.getMyProfile();
          break;
        case 'alumni':
          profile = await AlumniAPI.getMyProfile();
          break;
        case 'professor':
          profile = await ProfessorAPI.getMyProfile();
          break;
        default:
          profile = await StudentAPI.getMyProfile();
      }
      
      setState(() {
        _profileData = profile;
        _populateFields(profile);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void _populateFields(Map<String, dynamic> profile) {
    _firstNameController.text = profile['firstName'] ?? '';
    _lastNameController.text = profile['lastName'] ?? '';
    _emailController.text = profile['email'] ?? '';
    _phoneController.text = profile['phone'] ?? '';
    _bioController.text = profile['bio'] ?? '';
    _linkedinController.text = profile['linkedin'] ?? '';
    _githubController.text = profile['github'] ?? '';
    _portfolioController.text = profile['portfolio'] ?? '';
    
    _skills = List<String>.from(profile['skills'] ?? []);
    _interests = List<String>.from(profile['interests'] ?? []);
    
    // Role-specific fields
    if (_userRole == 'student') {
      _studentIdController.text = profile['studentId'] ?? '';
      _departmentController.text = profile['department'] ?? '';
      _yearController.text = profile['year']?.toString() ?? '';
      _gpaController.text = profile['gpa']?.toString() ?? '';
    } else if (_userRole == 'alumni') {
      _graduationYearController.text = profile['graduationYear']?.toString() ?? '';
      _companyController.text = profile['company'] ?? '';
      _positionController.text = profile['position'] ?? '';
      _experienceController.text = profile['experience']?.toString() ?? '';
    } else if (_userRole == 'professor') {
      _titleController.text = profile['title'] ?? '';
      _officeController.text = profile['office'] ?? '';
      _researchAreasController.text = (profile['researchAreas'] as List?)?.join(', ') ?? '';
      _qualificationsController.text = (profile['qualifications'] as List?)?.join(', ') ?? '';
    }
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final profileData = _buildProfileData();
      
      Map<String, dynamic> response;
      switch (_userRole) {
        case 'student':
          response = await StudentAPI.updateMyProfile(profileData);
          break;
        case 'alumni':
          response = await AlumniAPI.updateMyProfile(profileData);
          break;
        case 'professor':
          response = await ProfessorAPI.updateMyProfile(profileData);
          break;
        default:
          response = await StudentAPI.updateMyProfile(profileData);
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  bool _validateForm() {
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name is required')),
      );
      return false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Last name is required')),
      );
      return false;
    }
    return true;
  }

  Map<String, dynamic> _buildProfileData() {
    final data = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'github': _githubController.text.trim(),
      'portfolio': _portfolioController.text.trim(),
      'skills': _skills,
      'interests': _interests,
    };

    // Add role-specific fields
    if (_userRole == 'student') {
      final year = int.tryParse(_yearController.text.trim());
      final gpa = double.tryParse(_gpaController.text.trim());
      if (year != null) data['year'] = year;
      if (gpa != null) data['gpa'] = gpa;
      data.addAll({
        'studentId': _studentIdController.text.trim(),
        'department': _departmentController.text.trim(),
      });
    } else if (_userRole == 'alumni') {
      final graduationYear = int.tryParse(_graduationYearController.text.trim());
      final experience = int.tryParse(_experienceController.text.trim());
      if (graduationYear != null) data['graduationYear'] = graduationYear;
      if (experience != null) data['experience'] = experience;
      data.addAll({
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
      });
    } else if (_userRole == 'professor') {
      data.addAll({
        'title': _titleController.text.trim(),
        'office': _officeController.text.trim(),
        'researchAreas': _researchAreasController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'qualifications': _qualificationsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      });
    }

    return data;
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter skill'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final skill = controller.text.trim();
                if (skill.isNotEmpty && !_skills.contains(skill)) {
                  setState(() {
                    _skills.add(skill);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addInterest() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Interest'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter interest'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final interest = controller.text.trim();
                if (interest.isNotEmpty && !_interests.contains(interest)) {
                  setState(() {
                    _interests.add(interest);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading profile...'),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _profileData?['profilePicture'] != null
                            ? NetworkImage(_profileData!['profilePicture'])
                            : null,
                    child: _selectedImage == null && _profileData?['profilePicture'] == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Basic Information
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('First Name', _firstNameController, Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('Last Name', _lastNameController, Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField('Phone', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Bio', _bioController, Icons.info, maxLines: 3),
            
            const SizedBox(height: 32),
            
            // Social Links
            _buildSectionHeader('Social Links'),
            const SizedBox(height: 16),
            _buildTextField('LinkedIn', _linkedinController, Icons.link),
            const SizedBox(height: 16),
            _buildTextField('GitHub', _githubController, Icons.code),
            const SizedBox(height: 16),
            _buildTextField('Portfolio', _portfolioController, Icons.web),
            
            const SizedBox(height: 32),
            
            // Role-specific fields
            if (_userRole == 'student') ..._buildStudentFields(),
            if (_userRole == 'alumni') ..._buildAlumniFields(),
            if (_userRole == 'professor') ..._buildProfessorFields(),
            
            const SizedBox(height: 32),
            
            // Skills Section
            _buildSectionHeader('Skills'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._skills.map((skill) => Chip(
                  label: Text(skill),
                  onDeleted: () {
                    setState(() {
                      _skills.remove(skill);
                    });
                  },
                )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add Skill'),
                  onPressed: _addSkill,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Interests Section
            _buildSectionHeader('Interests'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._interests.map((interest) => Chip(
                  label: Text(interest),
                  onDeleted: () {
                    setState(() {
                      _interests.remove(interest);
                    });
                  },
                )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add Interest'),
                  onPressed: _addInterest,
                ),
              ],
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  List<Widget> _buildStudentFields() {
    return [
      _buildSectionHeader('Student Information'),
      const SizedBox(height: 16),
      _buildTextField('Student ID', _studentIdController, Icons.badge),
      const SizedBox(height: 16),
      _buildTextField('Department', _departmentController, Icons.school),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField('Year', _yearController, Icons.calendar_today, keyboardType: TextInputType.number),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField('GPA', _gpaController, Icons.grade, keyboardType: TextInputType.number),
          ),
        ],
      ),
      const SizedBox(height: 32),
    ];
  }

  List<Widget> _buildAlumniFields() {
    return [
      _buildSectionHeader('Alumni Information'),
      const SizedBox(height: 16),
      _buildTextField('Graduation Year', _graduationYearController, Icons.calendar_today, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('Company', _companyController, Icons.business),
      const SizedBox(height: 16),
      _buildTextField('Position', _positionController, Icons.work),
      const SizedBox(height: 16),
      _buildTextField('Years of Experience', _experienceController, Icons.timeline, keyboardType: TextInputType.number),
      const SizedBox(height: 32),
    ];
  }

  List<Widget> _buildProfessorFields() {
    return [
      _buildSectionHeader('Professor Information'),
      const SizedBox(height: 16),
      _buildTextField('Title', _titleController, Icons.person),
      const SizedBox(height: 16),
      _buildTextField('Office', _officeController, Icons.location_on),
      const SizedBox(height: 16),
      _buildTextField('Research Areas (comma-separated)', _researchAreasController, Icons.science, maxLines: 2),
      const SizedBox(height: 16),
      _buildTextField('Qualifications (comma-separated)', _qualificationsController, Icons.school, maxLines: 2),
      const SizedBox(height: 32),
    ];
  }
}
