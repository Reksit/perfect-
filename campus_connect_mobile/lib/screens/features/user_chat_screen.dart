import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      department: json['department'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
    );
  }
}

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<ChatUser> _allUsers = [];
  List<ChatUser> _conversations = [];
  List<Message> _currentMessages = [];
  ChatUser? _selectedUser;
  bool _loading = true;
  bool _loadingMessages = false;
  String _searchQuery = '';

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      _allUsers = [
        ChatUser(
          id: '2',
          name: 'Dr. Sarah Johnson',
          email: 'sarah.johnson@university.edu',
          role: 'PROFESSOR',
          department: 'Computer Science',
        ),
        ChatUser(
          id: '3',
          name: 'Mike Chen',
          email: 'mike.chen@alumni.edu',
          role: 'ALUMNI',
          department: 'Engineering',
          lastMessage: 'Thanks for the career advice!',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatUser(
          id: '4',
          name: 'Emily Davis',
          email: 'emily.davis@student.edu',
          role: 'STUDENT',
          department: 'Computer Science',
          lastMessage: 'Can we study together for the exam?',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          unreadCount: 2,
        ),
        ChatUser(
          id: '5',
          name: 'Robert Wilson',
          email: 'robert.wilson@management.edu',
          role: 'MANAGEMENT',
          department: 'Administration',
        ),
        ChatUser(
          id: '6',
          name: 'Lisa Anderson',
          email: 'lisa.anderson@alumni.edu',
          role: 'ALUMNI',
          department: 'Business',
          lastMessage: 'The networking event was great!',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load users: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadConversations() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _conversations = _allUsers.where((user) => 
          user.lastMessage != null && user.lastMessage!.isNotEmpty).toList();
      
      // Sort by last message time
      _conversations.sort((a, b) => 
          (b.lastMessageTime ?? DateTime(1970)).compareTo(
              a.lastMessageTime ?? DateTime(1970)));

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load conversations: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMessages(ChatUser user) async {
    setState(() {
      _loadingMessages = true;
      _selectedUser = user;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate sample messages
      _currentMessages = _generateSampleMessages(user);

      setState(() {
        _loadingMessages = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _loadingMessages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load messages: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Message> _generateSampleMessages(ChatUser user) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final now = DateTime.now();

    switch (user.id) {
      case '3': // Mike Chen - Alumni
        return [
          Message(
            id: '1',
            senderId: currentUser?.id ?? '1',
            senderName: currentUser?.name ?? 'You',
            receiverId: user.id,
            receiverName: user.name,
            message: 'Hi Mike! I saw your profile and would love to get some career advice.',
            timestamp: now.subtract(const Duration(hours: 4)),
            read: true,
          ),
          Message(
            id: '2',
            senderId: user.id,
            senderName: user.name,
            receiverId: currentUser?.id ?? '1',
            receiverName: currentUser?.name ?? 'You',
            message: 'Hello! I\'d be happy to help. What specific area are you interested in?',
            timestamp: now.subtract(const Duration(hours: 3)),
            read: true,
          ),
          Message(
            id: '3',
            senderId: currentUser?.id ?? '1',
            senderName: currentUser?.name ?? 'You',
            receiverId: user.id,
            receiverName: user.name,
            message: 'I\'m particularly interested in software engineering roles at tech companies.',
            timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
            read: true,
          ),
          Message(
            id: '4',
            senderId: user.id,
            senderName: user.name,
            receiverId: currentUser?.id ?? '1',
            receiverName: currentUser?.name ?? 'You',
            message: 'Thanks for the career advice!',
            timestamp: now.subtract(const Duration(hours: 2)),
            read: true,
          ),
        ];

      case '4': // Emily Davis - Student
        return [
          Message(
            id: '5',
            senderId: user.id,
            senderName: user.name,
            receiverId: currentUser?.id ?? '1',
            receiverName: currentUser?.name ?? 'You',
            message: 'Hey! Are you taking Database Systems this semester?',
            timestamp: now.subtract(const Duration(hours: 1)),
            read: true,
          ),
          Message(
            id: '6',
            senderId: currentUser?.id ?? '1',
            senderName: currentUser?.name ?? 'You',
            receiverId: user.id,
            receiverName: user.name,
            message: 'Yes, I am! Are you struggling with it too?',
            timestamp: now.subtract(const Duration(minutes: 45)),
            read: true,
          ),
          Message(
            id: '7',
            senderId: user.id,
            senderName: user.name,
            receiverId: currentUser?.id ?? '1',
            receiverName: currentUser?.name ?? 'You',
            message: 'Can we study together for the exam?',
            timestamp: now.subtract(const Duration(minutes: 30)),
            read: false,
          ),
        ];

      default:
        return [];
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedUser == null) return;

    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final messageText = _messageController.text.trim();
    _messageController.clear();

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser?.id ?? '1',
      senderName: currentUser?.name ?? 'You',
      receiverId: _selectedUser!.id,
      receiverName: _selectedUser!.name,
      message: messageText,
      timestamp: DateTime.now(),
      read: false,
    );

    setState(() {
      _currentMessages.add(newMessage);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUsersList() {
    final filteredUsers = _allUsers.where((user) =>
        user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.department.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Users list
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                          Text(
                            user.department,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _loadMessages(user),
                    child: const Text('Chat'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationsList() {
    if (_conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with someone!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final user = _conversations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (user.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${user.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(user.name),
            subtitle: Text(
              user.lastMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: user.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Text(
              user.lastMessageTime != null
                  ? _formatTime(user.lastMessageTime!)
                  : '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () => _loadMessages(user),
          ),
        );
      },
    );
  }

  Widget _buildChatInterface() {
    if (_selectedUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a user to start chatting',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _selectedUser!.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedUser!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_selectedUser!.role} • ${_selectedUser!.department}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedUser = null;
                    _currentMessages.clear();
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: _loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = _currentMessages[index];
                    final isMe = message.senderId == (currentUser?.id ?? '1');

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: _buildChatInterface(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Conversations'),
            Tab(text: 'All Users'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _loadUsers();
              _loadConversations();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConversationsList(),
                _buildUsersList(),
              ],
            ),
    );
  }
}
