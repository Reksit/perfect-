import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // full-time, part-time, internship, contract
  final String description;
  final List<String> requirements;
  final String salaryRange;
  final DateTime postedDate;
  final DateTime? deadline;
  final String postedBy;
  final bool isActive;
  final List<String> skills;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.requirements,
    required this.salaryRange,
    required this.postedDate,
    this.deadline,
    required this.postedBy,
    this.isActive = true,
    required this.skills,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      type: json['type'],
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      salaryRange: json['salaryRange'] ?? '',
      postedDate: DateTime.parse(json['postedDate']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      postedBy: json['postedBy'],
      isActive: json['isActive'] ?? true,
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'requirements': requirements,
      'salaryRange': salaryRange,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'postedBy': postedBy,
      'isActive': isActive,
      'skills': skills,
    };
  }
}

class JobApplication {
  final String id;
  final String jobId;
  final String applicantId;
  final String coverLetter;
  final String resumeUrl;
  final DateTime appliedDate;
  final String status; // applied, reviewing, interview, rejected, accepted

  JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.coverLetter,
    required this.resumeUrl,
    required this.appliedDate,
    required this.status,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['jobId'],
      applicantId: json['applicantId'],
      coverLetter: json['coverLetter'],
      resumeUrl: json['resumeUrl'],
      appliedDate: DateTime.parse(json['appliedDate']),
      status: json['status'],
    );
  }
}

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  List<JobApplication> _myApplications = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedType = '';
  String _selectedLocation = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
    _loadMyApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      setState(() {
        _loading = true;
      });

      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      final sampleJobs = [
        Job(
          id: '1',
          title: 'Software Engineer',
          company: 'TechCorp Inc.',
          location: 'San Francisco, CA',
          type: 'full-time',
          description: 'We are looking for a talented Software Engineer to join our team...',
          requirements: [
            'Bachelor\'s degree in Computer Science',
            '3+ years of experience with Flutter/React',
            'Experience with REST APIs',
            'Strong problem-solving skills'
          ],
          salaryRange: '\$80,000 - \$120,000',
          postedDate: DateTime.now().subtract(const Duration(days: 2)),
          deadline: DateTime.now().add(const Duration(days: 30)),
          postedBy: 'hr@techcorp.com',
          skills: ['Flutter', 'Dart', 'React', 'JavaScript', 'REST API'],
        ),
        Job(
          id: '2',
          title: 'Data Analyst Intern',
          company: 'DataFlow Solutions',
          location: 'Remote',
          type: 'internship',
          description: 'Summer internship opportunity for data analysis and visualization...',
          requirements: [
            'Currently pursuing degree in Data Science/Statistics',
            'Knowledge of Python/R',
            'Familiarity with SQL',
            'Strong analytical skills'
          ],
          salaryRange: '\$15 - \$20/hour',
          postedDate: DateTime.now().subtract(const Duration(days: 5)),
          deadline: DateTime.now().add(const Duration(days: 20)),
          postedBy: 'internships@dataflow.com',
          skills: ['Python', 'SQL', 'Data Analysis', 'Statistics'],
        ),
        Job(
          id: '3',
          title: 'Product Manager',
          company: 'Innovation Labs',
          location: 'New York, NY',
          type: 'full-time',
          description: 'Lead product strategy and development for our mobile applications...',
          requirements: [
            'MBA or equivalent experience',
            '5+ years in product management',
            'Experience with mobile apps',
            'Strong leadership skills'
          ],
          salaryRange: '\$110,000 - \$150,000',
          postedDate: DateTime.now().subtract(const Duration(days: 1)),
          deadline: DateTime.now().add(const Duration(days: 45)),
          postedBy: 'careers@innovationlabs.com',
          skills: ['Product Management', 'Strategy', 'Mobile Apps', 'Leadership'],
        ),
      ];
      
      setState(() {
        _jobs = sampleJobs;
        _filteredJobs = sampleJobs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load jobs: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMyApplications() async {
    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _myApplications = [
          JobApplication(
            id: '1',
            jobId: '1',
            applicantId: 'current_user_id',
            coverLetter: 'I am very interested in this position...',
            resumeUrl: 'resume.pdf',
            appliedDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'reviewing',
          ),
        ];
      });
    } catch (e) {
      // Handle error
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final matchesSearch = _searchQuery.isEmpty ||
            job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.skills.any((skill) => skill.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        final matchesType = _selectedType.isEmpty || job.type == _selectedType;
        final matchesLocation = _selectedLocation.isEmpty || 
            job.location.toLowerCase().contains(_selectedLocation.toLowerCase());
        
        return matchesSearch && matchesType && matchesLocation && job.isActive;
      }).toList();
    });
  }

  Future<void> _applyToJob(Job job) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final coverLetterController = TextEditingController();
    bool hasResume = false; // Check if user has uploaded resume

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Apply to ${job.title}'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.company} - ${job.location}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Resume section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasResume ? Icons.check_circle : Icons.upload_file,
                            color: hasResume ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hasResume ? 'Resume uploaded' : 'Upload your resume',
                              style: TextStyle(
                                color: hasResume ? Colors.green : Colors.grey[600],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement file picker
                              setDialogState(() {
                                hasResume = true;
                              });
                            },
                            child: Text(hasResume ? 'Change' : 'Upload'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cover letter
                    TextField(
                      controller: coverLetterController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Cover Letter',
                        hintText: 'Tell them why you\'re interested in this role...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
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
                  onPressed: hasResume ? () {
                    Navigator.of(context).pop();
                    _submitApplication(job, coverLetterController.text);
                  } : null,
                  child: const Text('Submit Application'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitApplication(Job job, String coverLetter) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh applications
      _loadMyApplications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.company} • ${job.location}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Job type and salary
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        job.type.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      job.salaryRange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        
                        // Requirements
                        Text(
                          'Requirements',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...job.requirements.map((req) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                                  Expanded(
                                    child: Text(req, style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 24),
                        
                        // Skills
                        Text(
                          'Required Skills',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: job.skills.map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Additional info
                        if (job.deadline != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Application deadline: ${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Posted ${DateTime.now().difference(job.postedDate).inDays} days ago',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Apply button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Apply Now',
                    onPressed: () {
                      Navigator.of(context).pop();
                      _applyToJob(job);
                    },
                    icon: Icons.send,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(Job job) {
    final isApplied = _myApplications.any((app) => app.jobId == job.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Applied',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.type.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                job.salaryRange,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              
              // Skills preview
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: job.skills.take(3).map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(fontSize: 10),
                      ),
                    )).toList(),
              ),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${DateTime.now().difference(job.postedDate).inDays} days ago',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  if (!isApplied)
                    TextButton(
                      onPressed: () => _applyToJob(job),
                      child: const Text('Apply'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    final job = _jobs.firstWhere((j) => j.id == application.jobId, 
        orElse: () => _jobs.first);
    
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty;
    
    switch (application.status) {
      case 'reviewing':
        statusColor = Colors.orange;
        statusIcon = Icons.visibility;
        break;
      case 'interview':
        statusColor = Colors.blue;
        statusIcon = Icons.person;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        application.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Applied ${DateTime.now().difference(application.appliedDate).inDays} days ago',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Jobs'),
            Tab(text: 'My Applications'),
            Tab(text: 'Saved Jobs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Jobs Tab
          Column(
            children: [
              // Search and filters
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search jobs, companies, or skills...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _filterJobs();
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterJobs();
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All Types'),
                            selected: _selectedType.isEmpty,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = '';
                              });
                              _filterJobs();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Full-time'),
                            selected: _selectedType == 'full-time',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? 'full-time' : '';
                              });
                              _filterJobs();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Internship'),
                            selected: _selectedType == 'internship',
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? 'internship' : '';
                              });
                              _filterJobs();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Remote'),
                            selected: _selectedLocation == 'remote',
                            onSelected: (selected) {
                              setState(() {
                                _selectedLocation = selected ? 'remote' : '';
                              });
                              _filterJobs();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Jobs list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredJobs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No jobs found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search criteria',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadJobs,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredJobs.length,
                              itemBuilder: (context, index) {
                                return _buildJobCard(_filteredJobs[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
          
          // My Applications Tab
          _myApplications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No applications yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start applying to jobs to see them here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myApplications.length,
                  itemBuilder: (context, index) {
                    return _buildApplicationCard(_myApplications[index]);
                  },
                ),
          
          // Saved Jobs Tab
          const Center(
            child: Text('Saved jobs feature coming soon!'),
          ),
        ],
      ),
    );
  }
}
