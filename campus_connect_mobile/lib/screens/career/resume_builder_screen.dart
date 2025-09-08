import 'package:flutter/material.dart';
import '../../services/api_extensions.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _selectedTemplateId = '';

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  // Dynamic Lists
  List<Map<String, dynamic>> _experiences = [];
  List<Map<String, dynamic>> _education = [];
  List<Map<String, dynamic>> _skills = [];
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _certifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadResumeData();
    _loadTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadResumeData() async {
    setState(() => _isLoading = true);
    try {
      final resumeData = await ResumeAPI.getUserResume();
      if (resumeData != null) {
        _populateFormFromData(resumeData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await ResumeAPI.getResumeTemplates();
      setState(() {
        _templates = List<Map<String, dynamic>>.from(templates);
        if (_templates.isNotEmpty && _selectedTemplateId.isEmpty) {
          _selectedTemplateId = _templates.first['_id'] ?? '';
        }
      });
    } catch (e) {
      print('Error loading templates: $e');
    }
  }

  void _populateFormFromData(Map<String, dynamic> data) {
    setState(() {
      _fullNameController.text = data['personalInfo']?['fullName'] ?? '';
      _emailController.text = data['personalInfo']?['email'] ?? '';
      _phoneController.text = data['personalInfo']?['phone'] ?? '';
      _addressController.text = data['personalInfo']?['address'] ?? '';
      _linkedinController.text = data['personalInfo']?['linkedin'] ?? '';
      _websiteController.text = data['personalInfo']?['website'] ?? '';
      _summaryController.text = data['summary'] ?? '';
      
      _experiences = List<Map<String, dynamic>>.from(data['experiences'] ?? []);
      _education = List<Map<String, dynamic>>.from(data['education'] ?? []);
      _skills = List<Map<String, dynamic>>.from(data['skills'] ?? []);
      _projects = List<Map<String, dynamic>>.from(data['projects'] ?? []);
      _certifications = List<Map<String, dynamic>>.from(data['certifications'] ?? []);
      _selectedTemplateId = data['templateId'] ?? (_templates.isNotEmpty ? _templates.first['_id'] : '');
    });
  }

  Future<void> _saveResume() async {
    setState(() => _isSaving = true);
    try {
      final resumeData = {
        'personalInfo': {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'linkedin': _linkedinController.text,
          'website': _websiteController.text,
        },
        'summary': _summaryController.text,
        'experiences': _experiences,
        'education': _education,
        'skills': _skills,
        'projects': _projects,
        'certifications': _certifications,
        'templateId': _selectedTemplateId,
      };

      await ResumeAPI.saveResume(resumeData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving resume: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _generatePDF() async {
    try {
      final pdfUrl = await ResumeAPI.generateResumePDF(_selectedTemplateId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generated: $pdfUrl'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Resume Builder',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Experience'),
            Tab(text: 'Education'),
            Tab(text: 'Skills'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveResume,
            tooltip: 'Save Resume',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            )
          : Column(
              children: [
                // Template Selector
                _buildTemplateSelector(),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalInfoTab(),
                      _buildExperienceTab(),
                      _buildEducationTab(),
                      _buildSkillsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTemplateSelector() {
    if (_templates.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Template',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                final isSelected = _selectedTemplateId == template['_id'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTemplateId = template['_id'] ?? '';
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1565C0) : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template['name'] ?? 'Template',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildFormField(
            label: 'Full Name',
            controller: _fullNameController,
            icon: Icons.person,
            hint: 'Enter your full name',
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Phone',
            controller: _phoneController,
            icon: Icons.phone,
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on,
            hint: 'Enter your address',
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'LinkedIn Profile',
            controller: _linkedinController,
            icon: Icons.link,
            hint: 'LinkedIn profile URL',
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Website/Portfolio',
            controller: _websiteController,
            icon: Icons.web,
            hint: 'Personal website or portfolio URL',
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 16),

          _buildFormField(
            label: 'Professional Summary',
            controller: _summaryController,
            icon: Icons.description,
            hint: 'Write a brief professional summary',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Work Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_experiences.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No work experience added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your professional experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_experiences.length, (index) {
              final experience = _experiences[index];
              return _buildExperienceCard(experience, index);
            }),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Education',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addEducation,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_education.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No education added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your educational background',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_education.length, (index) {
              final edu = _education[index];
              return _buildEducationCard(edu, index);
            }),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skills & Projects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _addSkill,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Skill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addProject,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Skills Section
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          if (_skills.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'No skills added yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_skills.length, (index) {
                final skill = _skills[index];
                return _buildSkillChip(skill, index);
              }),
            ),

          const SizedBox(height: 24),

          // Projects Section
          const Text(
            'Projects',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          if (_projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.code_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No projects added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_projects.length, (index) {
              final project = _projects[index];
              return _buildProjectCard(project, index);
            }),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1565C0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  experience['position'] ?? 'Position',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeExperience(index),
              ),
            ],
          ),
          Text(
            experience['company'] ?? 'Company',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${experience['startDate'] ?? 'Start'} - ${experience['endDate'] ?? 'End'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (experience['description'] != null && experience['description'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> education, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  education['degree'] ?? 'Degree',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeEducation(index),
              ),
            ],
          ),
          Text(
            education['institution'] ?? 'Institution',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${education['startYear'] ?? 'Start'} - ${education['endYear'] ?? 'End'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (education['gpa'] != null && education['gpa'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'GPA: ${education['gpa']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> skill, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill['name'] ?? 'Skill',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeSkill(index),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['name'] ?? 'Project Name',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeProject(index),
              ),
            ],
          ),
          if (project['description'] != null && project['description'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
          if (project['technologies'] != null && project['technologies'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (project['technologies'] as List).map<Widget>((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tech.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Add/Remove Methods
  void _addExperience() {
    _showExperienceDialog();
  }

  void _addEducation() {
    _showEducationDialog();
  }

  void _addSkill() {
    _showSkillDialog();
  }

  void _addProject() {
    _showProjectDialog();
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
  }

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _removeProject(int index) {
    setState(() {
      _projects.removeAt(index);
    });
  }

  // Dialog Methods
  void _showExperienceDialog([Map<String, dynamic>? existingExperience]) {
    final positionController = TextEditingController(text: existingExperience?['position'] ?? '');
    final companyController = TextEditingController(text: existingExperience?['company'] ?? '');
    final startDateController = TextEditingController(text: existingExperience?['startDate'] ?? '');
    final endDateController = TextEditingController(text: existingExperience?['endDate'] ?? '');
    final descriptionController = TextEditingController(text: existingExperience?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Work Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (positionController.text.isNotEmpty && companyController.text.isNotEmpty) {
                setState(() {
                  _experiences.add({
                    'position': positionController.text,
                    'company': companyController.text,
                    'startDate': startDateController.text,
                    'endDate': endDateController.text,
                    'description': descriptionController.text,
                  });
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEducationDialog() {
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();
    final gpaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startYearController,
                      decoration: const InputDecoration(
                        labelText: 'Start Year',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endYearController,
                      decoration: const InputDecoration(
                        labelText: 'End Year',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gpaController,
                decoration: const InputDecoration(
                  labelText: 'GPA (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (degreeController.text.isNotEmpty && institutionController.text.isNotEmpty) {
                setState(() {
                  _education.add({
                    'degree': degreeController.text,
                    'institution': institutionController.text,
                    'startYear': startYearController.text,
                    'endYear': endYearController.text,
                    'gpa': gpaController.text,
                  });
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSkillDialog() {
    final skillController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextField(
          controller: skillController,
          decoration: const InputDecoration(
            labelText: 'Skill Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (skillController.text.isNotEmpty) {
                setState(() {
                  _skills.add({'name': skillController.text});
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologiesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: technologiesController,
                decoration: const InputDecoration(
                  labelText: 'Technologies (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final technologies = technologiesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                
                setState(() {
                  _projects.add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'technologies': technologies,
                  });
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
