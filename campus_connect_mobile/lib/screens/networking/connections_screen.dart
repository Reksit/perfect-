import 'package:flutter/material.dart';
import '../../services/api_extensions.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _suggestedConnections = [];
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadConnections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    try {
      // Load all connection data
      final connections = await ConnectionAPI.getConnections();
      final pendingRequests = await ConnectionAPI.getPendingRequests();
      final sentRequests = await ConnectionAPI.getSentRequests();
      final suggested = await ConnectionAPI.getSuggestedConnections();

      setState(() {
        _connections = List<Map<String, dynamic>>.from(connections);
        _pendingRequests = List<Map<String, dynamic>>.from(pendingRequests);
        _sentRequests = List<Map<String, dynamic>>.from(sentRequests);
        _suggestedConnections = List<Map<String, dynamic>>.from(suggested);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading connections: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendConnectionRequest(String userId, [String? message]) async {
    try {
      await ConnectionAPI.sendConnectionRequest(userId, message ?? 'I would like to connect with you.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.acceptConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request accepted!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.rejectConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeConnection(String connectionId) async {
    try {
      await ConnectionAPI.removeConnection(connectionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection removed'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing connection: $e'),
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
          'Professional Network',
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
          tabs: [
            Tab(
              text: 'My Network',
              icon: Badge(
                label: Text('${_connections.length}'),
                child: const Icon(Icons.group),
              ),
            ),
            Tab(
              text: 'Requests',
              icon: Badge(
                label: Text('${_pendingRequests.length}'),
                child: const Icon(Icons.person_add),
              ),
            ),
            Tab(
              text: 'Sent',
              icon: Badge(
                label: Text('${_sentRequests.length}'),
                child: const Icon(Icons.send),
              ),
            ),
            Tab(
              text: 'Discover',
              icon: Badge(
                label: Text('${_suggestedConnections.length}'),
                child: const Icon(Icons.explore),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConnections,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyNetworkTab(),
                _buildRequestsTab(),
                _buildSentRequestsTab(),
                _buildDiscoverTab(),
              ],
            ),
    );
  }

  Widget _buildMyNetworkTab() {
    if (_connections.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No connections yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start building your professional network',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConnections,
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your network...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1565C0)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          // Connections List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _connections.length,
              itemBuilder: (context, index) {
                final connection = _connections[index];
                return _buildConnectionCard(connection, showRemoveButton: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Connection requests will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConnections,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildSentRequestsTab() {
    if (_sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No sent requests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your sent requests will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConnections,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          return _buildSentRequestCard(request);
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    if (_suggestedConnections.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No suggestions available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new connection suggestions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConnections,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suggestedConnections.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestedConnections[index];
          return _buildSuggestionCard(suggestion);
        },
      ),
    );
  }

  Widget _buildConnectionCard(Map<String, dynamic> connection, {bool showRemoveButton = false}) {
    final user = connection['user'] ?? connection;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF1565C0),
          backgroundImage: user['profilePicture'] != null
              ? NetworkImage(user['profilePicture'])
              : null,
          child: user['profilePicture'] == null
              ? Text(
                  (user['fullName']?[0] ?? user['name']?[0] ?? 'U').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user['fullName'] ?? user['name'] ?? 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['currentPosition'] != null) ...[
              const SizedBox(height: 4),
              Text(
                user['currentPosition'],
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                ),
              ),
            ],
            if (user['company'] != null) ...[
              const SizedBox(height: 2),
              Text(
                user['company'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
            if (connection['mutualConnections'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${connection['mutualConnections']} mutual connections',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.message, color: Color(0xFF1565C0)),
              onPressed: () => _startConversation(user),
              tooltip: 'Message',
            ),
            if (showRemoveButton)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _confirmRemoveConnection(connection['_id'] ?? ''),
                tooltip: 'Remove Connection',
              ),
          ],
        ),
        onTap: () => _showUserProfile(user),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final user = request['requester'] ?? request['user'] ?? request;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1565C0),
                  backgroundImage: user['profilePicture'] != null
                      ? NetworkImage(user['profilePicture'])
                      : null,
                  child: user['profilePicture'] == null
                      ? Text(
                          (user['fullName']?[0] ?? user['name']?[0] ?? 'U').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['fullName'] ?? user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (user['currentPosition'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user['currentPosition'],
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (user['company'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user['company'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (request['message'] != null && request['message'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptConnectionRequest(request['_id'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectConnectionRequest(request['_id'] ?? ''),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestCard(Map<String, dynamic> request) {
    final user = request['recipient'] ?? request['user'] ?? request;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF1565C0),
          backgroundImage: user['profilePicture'] != null
              ? NetworkImage(user['profilePicture'])
              : null,
          child: user['profilePicture'] == null
              ? Text(
                  (user['fullName']?[0] ?? user['name']?[0] ?? 'U').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user['fullName'] ?? user['name'] ?? 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['currentPosition'] != null) ...[
              const SizedBox(height: 4),
              Text(
                user['currentPosition'],
                style: const TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatDate(request['createdAt']),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        onTap: () => _showUserProfile(user),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final user = suggestion['user'] ?? suggestion;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1565C0),
                  backgroundImage: user['profilePicture'] != null
                      ? NetworkImage(user['profilePicture'])
                      : null,
                  child: user['profilePicture'] == null
                      ? Text(
                          (user['fullName']?[0] ?? user['name']?[0] ?? 'U').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['fullName'] ?? user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (user['currentPosition'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user['currentPosition'],
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (user['company'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user['company'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (suggestion['reason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion['reason'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConnectionRequestDialog(user),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showUserProfile(user),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString.toString());
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return '';
    }
  }

  void _showConnectionRequestDialog(Map<String, dynamic> user) {
    _messageController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect with ${user['fullName'] ?? user['name'] ?? 'User'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a personal message (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'I\'d like to connect with you...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendConnectionRequest(
                user['_id'] ?? '',
                _messageController.text.isEmpty ? null : _messageController.text,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveConnection(String connectionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Connection'),
        content: const Text('Are you sure you want to remove this connection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _removeConnection(connectionId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _startConversation(Map<String, dynamic> user) {
    // Navigate to chat screen with this user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${user['fullName'] ?? user['name'] ?? 'User'}'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['fullName'] ?? user['name'] ?? 'User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['currentPosition'] != null) 
              Text('Position: ${user['currentPosition']}'),
            if (user['company'] != null) 
              Text('Company: ${user['company']}'),
            if (user['location'] != null) 
              Text('Location: ${user['location']}'),
            if (user['bio'] != null) ...[
              const SizedBox(height: 8),
              const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user['bio']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
