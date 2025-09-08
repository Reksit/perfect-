import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class FileItem {
  final String id;
  final String name;
  final String type; // resume, document, image, etc.
  final int size; // in bytes
  final DateTime uploadedAt;
  final String url;
  final bool isPublic;
  final Map<String, dynamic>? atsAnalysis;

  FileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.url,
    this.isPublic = false,
    this.atsAnalysis,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      url: json['url'],
      isPublic: json['isPublic'] ?? false,
      atsAnalysis: json['atsAnalysis'],
    );
  }
}

class FileManagementScreen extends StatefulWidget {
  const FileManagementScreen({super.key});

  @override
  State<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<FileItem> _allFiles = [];
  List<FileItem> _resumes = [];
  List<FileItem> _documents = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    try {
      setState(() {
        _loading = true;
      });

      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      final sampleFiles = [
        FileItem(
          id: '1',
          name: 'John_Doe_Resume_2024.pdf',
          type: 'resume',
          size: 1024 * 256, // 256KB
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          url: 'https://example.com/resume.pdf',
          isPublic: true,
          atsAnalysis: {
            'score': 85,
            'strengths': ['Strong technical skills', 'Relevant experience', 'Good formatting'],
            'improvements': ['Add more quantified achievements', 'Include keywords for target role'],
            'keywords': ['Flutter', 'Dart', 'Mobile Development', 'React', 'JavaScript'],
            'missingKeywords': ['AWS', 'DevOps', 'Agile', 'Scrum'],
          },
        ),
        FileItem(
          id: '2',
          name: 'Cover_Letter_TechCorp.pdf',
          type: 'document',
          size: 1024 * 128, // 128KB
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          url: 'https://example.com/cover-letter.pdf',
          isPublic: false,
        ),
        FileItem(
          id: '3',
          name: 'Portfolio_Screenshots.zip',
          type: 'document',
          size: 1024 * 1024 * 5, // 5MB
          uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
          url: 'https://example.com/portfolio.zip',
          isPublic: false,
        ),
        FileItem(
          id: '4',
          name: 'Certification_Flutter.pdf',
          type: 'document',
          size: 1024 * 512, // 512KB
          uploadedAt: DateTime.now().subtract(const Duration(days: 14)),
          url: 'https://example.com/certification.pdf',
          isPublic: true,
        ),
      ];
      
      setState(() {
        _allFiles = sampleFiles;
        _resumes = sampleFiles.where((f) => f.type == 'resume').toList();
        _documents = sampleFiles.where((f) => f.type == 'document').toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load files: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadFile(String fileType) async {
    setState(() {
      _uploading = true;
    });

    try {
      // Simulate file picker and upload
      await Future.delayed(const Duration(seconds: 3));
      
      final newFile = FileItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'New_${fileType}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        type: fileType,
        size: 1024 * 200,
        uploadedAt: DateTime.now(),
        url: 'https://example.com/new-file.pdf',
        isPublic: fileType == 'resume',
      );

      setState(() {
        _allFiles.insert(0, newFile);
        if (fileType == 'resume') {
          _resumes.insert(0, newFile);
        } else {
          _documents.insert(0, newFile);
        }
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Start ATS analysis for resumes
      if (fileType == 'resume') {
        _analyzeResume(newFile);
      }
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeResume(FileItem resume) async {
    try {
      // Simulate ATS analysis
      await Future.delayed(const Duration(seconds: 5));
      
      final analysis = {
        'score': 78,
        'strengths': ['Clear structure', 'Relevant skills listed'],
        'improvements': ['Add more action verbs', 'Include quantified results'],
        'keywords': ['Flutter', 'Mobile Development'],
        'missingKeywords': ['Cloud', 'Testing', 'CI/CD'],
      };

      setState(() {
        final index = _allFiles.indexWhere((f) => f.id == resume.id);
        if (index != -1) {
          _allFiles[index] = FileItem(
            id: resume.id,
            name: resume.name,
            type: resume.type,
            size: resume.size,
            uploadedAt: resume.uploadedAt,
            url: resume.url,
            isPublic: resume.isPublic,
            atsAnalysis: analysis,
          );
        }
        
        final resumeIndex = _resumes.indexWhere((f) => f.id == resume.id);
        if (resumeIndex != -1) {
          _resumes[resumeIndex] = _allFiles[index];
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ATS analysis completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ATS analysis failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile(FileItem file) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _allFiles.removeWhere((f) => f.id == file.id);
        _resumes.removeWhere((f) => f.id == file.id);
        _documents.removeWhere((f) => f.id == file.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleFileVisibility(FileItem file) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      final updatedFile = FileItem(
        id: file.id,
        name: file.name,
        type: file.type,
        size: file.size,
        uploadedAt: file.uploadedAt,
        url: file.url,
        isPublic: !file.isPublic,
        atsAnalysis: file.atsAnalysis,
      );

      setState(() {
        final index = _allFiles.indexWhere((f) => f.id == file.id);
        if (index != -1) {
          _allFiles[index] = updatedFile;
        }
        
        if (file.type == 'resume') {
          final resumeIndex = _resumes.indexWhere((f) => f.id == file.id);
          if (resumeIndex != -1) {
            _resumes[resumeIndex] = updatedFile;
          }
        } else {
          final docIndex = _documents.indexWhere((f) => f.id == file.id);
          if (docIndex != -1) {
            _documents[docIndex] = updatedFile;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedFile.isPublic 
              ? 'File is now visible to recruiters' 
              : 'File is now private'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update file visibility: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showATSAnalysis(FileItem file) {
    if (file.atsAnalysis == null) return;

    final analysis = file.atsAnalysis!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ATS Analysis Results',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Score
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'ATS Score: ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${analysis['score']}/100',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      CircularProgressIndicator(
                        value: analysis['score'] / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Strengths
                        _buildAnalysisSection(
                          'Strengths',
                          analysis['strengths'] ?? [],
                          Icons.check_circle,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        
                        // Improvements
                        _buildAnalysisSection(
                          'Areas for Improvement',
                          analysis['improvements'] ?? [],
                          Icons.warning,
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        
                        // Keywords found
                        _buildKeywordsSection(
                          'Keywords Found',
                          analysis['keywords'] ?? [],
                          Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        
                        // Missing keywords
                        _buildKeywordsSection(
                          'Missing Keywords',
                          analysis['missingKeywords'] ?? [],
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Download Detailed Report',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading report...')),
                      );
                    },
                    icon: Icons.download,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisSection(String title, List<dynamic> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildKeywordsSection(String title, List<dynamic> keywords, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((keyword) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    keyword.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'resume':
        return Icons.description;
      case 'document':
        return Icons.insert_drive_file;
      case 'image':
        return Icons.image;
      default:
        return Icons.file_present;
    }
  }

  Widget _buildFileCard(FileItem file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(file.type),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatFileSize(file.size),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTimeAgo(file.uploadedAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'download':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading file...')),
                        );
                        break;
                      case 'toggle_visibility':
                        _toggleFileVisibility(file);
                        break;
                      case 'analyze':
                        if (file.type == 'resume') {
                          _analyzeResume(file);
                        }
                        break;
                      case 'view_analysis':
                        _showATSAnalysis(file);
                        break;
                      case 'delete':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete File'),
                            content: Text('Are you sure you want to delete ${file.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteFile(file);
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_visibility',
                      child: Row(
                        children: [
                          Icon(file.isPublic ? Icons.visibility_off : Icons.visibility),
                          const SizedBox(width: 8),
                          Text(file.isPublic ? 'Make Private' : 'Make Public'),
                        ],
                      ),
                    ),
                    if (file.type == 'resume' && file.atsAnalysis == null)
                      const PopupMenuItem(
                        value: 'analyze',
                        child: Row(
                          children: [
                            Icon(Icons.analytics),
                            SizedBox(width: 8),
                            Text('Run ATS Analysis'),
                          ],
                        ),
                      ),
                    if (file.atsAnalysis != null)
                      const PopupMenuItem(
                        value: 'view_analysis',
                        child: Row(
                          children: [
                            Icon(Icons.assessment),
                            SizedBox(width: 8),
                            Text('View Analysis'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // File status and actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: file.isPublic ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        file.isPublic ? Icons.visibility : Icons.visibility_off,
                        size: 12,
                        color: file.isPublic ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        file.isPublic ? 'Public' : 'Private',
                        style: TextStyle(
                          fontSize: 12,
                          color: file.isPublic ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (file.type == 'resume' && file.atsAnalysis != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showATSAnalysis(file),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.analytics, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'ATS: ${file.atsAnalysis!['score']}%',
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
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
        title: const Text('File Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All Files'),
                  if (_allFiles.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _allFiles.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Resumes'),
                  if (_resumes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _resumes.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Documents'),
                  if (_documents.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _documents.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All Files
                _buildFilesList(_allFiles, 'all'),
                // Resumes
                _buildFilesList(_resumes, 'resume'),
                // Documents
                _buildFilesList(_documents, 'document'),
              ],
            ),
      floatingActionButton: _uploading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Upload File',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Upload Resume'),
                          subtitle: const Text('PDF files with ATS analysis'),
                          onTap: () {
                            Navigator.pop(context);
                            _uploadFile('resume');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: const Text('Upload Document'),
                          subtitle: const Text('Cover letters, certificates, etc.'),
                          onTap: () {
                            Navigator.pop(context);
                            _uploadFile('document');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload'),
            ),
    );
  }

  Widget _buildFilesList(List<FileItem> files, String type) {
    if (files.isEmpty) {
      String emptyMessage = 'No files uploaded yet';
      String emptySubtitle = 'Upload your first file to get started';
      
      if (type == 'resume') {
        emptyMessage = 'No resumes uploaded';
        emptySubtitle = 'Upload your resume to get ATS analysis';
      } else if (type == 'document') {
        emptyMessage = 'No documents uploaded';
        emptySubtitle = 'Upload documents like cover letters and certificates';
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: files.length,
        itemBuilder: (context, index) {
          return _buildFileCard(files[index]);
        },
      ),
    );
  }
}
