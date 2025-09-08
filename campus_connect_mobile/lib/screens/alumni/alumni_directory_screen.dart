import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feature_providers.dart';
import '../../services/api_extensions.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlumniData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlumniData() async {
    final alumniProvider = context.read<AlumniProvider>();
    await alumniProvider.loadVerifiedAlumni();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    try {
      final results = await AlumniDirectoryAPI.searchAlumni(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('Search failed: ${e.toString()}');
    }
  }

  Future<void> _sendConnectionRequest(Map<String, dynamic> alumni) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _ConnectionRequestDialog(alumniName: alumni['name'] ?? 'Alumni'),
    );

    if (result != null) {
      try {
        await ConnectionAPI.sendConnectionRequest(alumni['id'], result);
        _showSuccessSnackBar('Connection request sent successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to send connection request: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Directory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse', icon: Icon(Icons.people)),
            Tab(text: 'Search', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    return Consumer<AlumniProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading alumni',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAlumniData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.verifiedAlumni.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No alumni found'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAlumniData,
          child: _buildAlumniList(provider.verifiedAlumni),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search alumni by name, company, or skills...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _performSearch,
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchQuery.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Start typing to search alumni'),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No results found'),
                            ],
                          ),
                        )
                      : _buildAlumniList(_searchResults),
        ),
      ],
    );
  }

  Widget _buildAlumniList(List<dynamic> alumni) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alumni.length,
      itemBuilder: (context, index) {
        final alumnus = alumni[index];
        return _buildAlumniCard(alumnus);
      },
    );
  }

  Widget _buildAlumniCard(Map<String, dynamic> alumni) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: alumni['profileImage'] != null
                      ? NetworkImage(alumni['profileImage'])
                      : null,
                  child: alumni['profileImage'] == null
                      ? Text(
                          (alumni['name'] ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumni['name'] ?? 'Alumni',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (alumni['graduationYear'] != null)
                        Text(
                          'Class of ${alumni['graduationYear']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      if (alumni['department'] != null)
                        Text(
                          alumni['department'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (alumni['currentCompany'] != null || alumni['currentPosition'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (alumni['currentPosition'] != null)
                            Text(
                              alumni['currentPosition'],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (alumni['currentCompany'] != null)
                            Text(
                              alumni['currentCompany'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            if (alumni['bio'] != null) ...[
              Text(
                alumni['bio'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            
            if (alumni['skills'] != null && (alumni['skills'] as List).isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (alumni['skills'] as List).take(5).map((skill) {
                  return Chip(
                    label: Text(
                      skill.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[200],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (alumni['linkedinUrl'] != null)
                      IconButton(
                        onPressed: () {
                          // TODO: Open LinkedIn URL
                        },
                        icon: Icon(Icons.link, color: Colors.blue[700]),
                        tooltip: 'LinkedIn Profile',
                      ),
                    if (alumni['portfolio'] != null)
                      IconButton(
                        onPressed: () {
                          // TODO: Open portfolio URL
                        },
                        icon: Icon(Icons.web, color: Colors.green[700]),
                        tooltip: 'Portfolio',
                      ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _showAlumniProfile(alumni);
                      },
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('View Profile'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _sendConnectionRequest(alumni);
                      },
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Connect'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlumniProfile(Map<String, dynamic> alumni) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AlumniProfileModal(alumni: alumni),
    );
  }
}

class _ConnectionRequestDialog extends StatefulWidget {
  final String alumniName;

  const _ConnectionRequestDialog({required this.alumniName});

  @override
  State<_ConnectionRequestDialog> createState() => _ConnectionRequestDialogState();
}

class _ConnectionRequestDialogState extends State<_ConnectionRequestDialog> {
  final TextEditingController _messageController = TextEditingController(
    text: 'Hi! I would like to connect with you and learn from your experience.',
  );

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Connect with ${widget.alumniName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Send a connection request with a personalized message:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your message...',
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
            Navigator.pop(context, _messageController.text.trim());
          },
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}

class _AlumniProfileModal extends StatelessWidget {
  final Map<String, dynamic> alumni;

  const _AlumniProfileModal({required this.alumni});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            backgroundImage: alumni['profileImage'] != null
                                ? NetworkImage(alumni['profileImage'])
                                : null,
                            child: alumni['profileImage'] == null
                                ? Text(
                                    (alumni['name'] ?? 'A')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alumni['name'] ?? 'Alumni',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (alumni['graduationYear'] != null)
                                  Text('Class of ${alumni['graduationYear']}'),
                                if (alumni['department'] != null)
                                  Text(alumni['department']),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Professional Info
                      if (alumni['currentCompany'] != null || alumni['currentPosition'] != null) ...[
                        _buildSection(
                          'Current Position',
                          Icons.work,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (alumni['currentPosition'] != null)
                                Text(
                                  alumni['currentPosition'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (alumni['currentCompany'] != null)
                                Text(alumni['currentCompany']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Bio
                      if (alumni['bio'] != null) ...[
                        _buildSection('About', Icons.person, Text(alumni['bio'])),
                        const SizedBox(height: 24),
                      ],
                      
                      // Skills
                      if (alumni['skills'] != null && (alumni['skills'] as List).isNotEmpty) ...[
                        _buildSection(
                          'Skills',
                          Icons.star,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (alumni['skills'] as List).map((skill) {
                              return Chip(
                                label: Text(skill.toString()),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Experience
                      if (alumni['experience'] != null && (alumni['experience'] as List).isNotEmpty) ...[
                        _buildSection(
                          'Experience',
                          Icons.history,
                          Column(
                            children: (alumni['experience'] as List).map((exp) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(exp['position'] ?? ''),
                                  subtitle: Text(exp['company'] ?? ''),
                                  trailing: Text(exp['duration'] ?? ''),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
