import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // info, success, warning, error, reminder
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? actionData;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionData,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      actionData: json['actionData'],
    );
  }
}

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationItem> _allNotifications = [];
  List<NotificationItem> _unreadNotifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _loading = true;
      });

      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      final sampleNotifications = [
        NotificationItem(
          id: '1',
          title: 'Assessment Completed',
          message: 'You have successfully completed the Data Structures assessment with a score of 85%.',
          type: 'success',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        NotificationItem(
          id: '2',
          title: 'New Job Posting',
          message: 'A new Software Engineer position has been posted by TechCorp Inc. Check it out in the Job Board.',
          type: 'info',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          actionData: {'type': 'navigate', 'route': '/job-board', 'jobId': 'job123'},
        ),
        NotificationItem(
          id: '3',
          title: 'Connection Request',
          message: 'John Smith (Alumni) has sent you a connection request.',
          type: 'info',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          actionData: {'type': 'connection_request', 'userId': 'user123'},
        ),
        NotificationItem(
          id: '4',
          title: 'Event Reminder',
          message: 'Don\'t forget! The Tech Career Fair starts tomorrow at 10:00 AM.',
          type: 'reminder',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          actionData: {'type': 'navigate', 'route': '/events', 'eventId': 'event123'},
        ),
        NotificationItem(
          id: '5',
          title: 'Resume Updated',
          message: 'Your resume has been successfully updated and is now visible to recruiters.',
          type: 'success',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationItem(
          id: '6',
          title: 'Assignment Due Soon',
          message: 'Your Programming Fundamentals assignment is due in 2 days.',
          type: 'warning',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NotificationItem(
          id: '7',
          title: 'System Maintenance',
          message: 'The platform will undergo maintenance on Saturday from 2:00 AM to 4:00 AM.',
          type: 'warning',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
        NotificationItem(
          id: '8',
          title: 'Welcome to ClassApp!',
          message: 'Welcome to our platform! Complete your profile to get started.',
          type: 'info',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          isRead: true,
        ),
      ];
      
      setState(() {
        _allNotifications = sampleNotifications;
        _unreadNotifications = sampleNotifications.where((n) => !n.isRead).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        final index = _allNotifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _allNotifications[index] = NotificationItem(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            timestamp: notification.timestamp,
            isRead: true,
            actionData: notification.actionData,
          );
        }
        _unreadNotifications.removeWhere((n) => n.id == notification.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as read: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _allNotifications = _allNotifications.map((n) => NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          timestamp: n.timestamp,
          isRead: true,
          actionData: n.actionData,
        )).toList();
        _unreadNotifications.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark all as read: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _allNotifications.removeWhere((n) => n.id == notification.id);
        _unreadNotifications.removeWhere((n) => n.id == notification.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notification: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNotificationAction(NotificationItem notification) {
    if (notification.actionData == null) return;

    final actionType = notification.actionData!['type'];
    
    switch (actionType) {
      case 'navigate':
        final route = notification.actionData!['route'];
        // TODO: Navigate to the specified route
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to $route')),
        );
        break;
        
      case 'connection_request':
        _showConnectionRequestDialog(notification);
        break;
        
      default:
        break;
    }
    
    // Mark as read when action is taken
    if (!notification.isRead) {
      _markAsRead(notification);
    }
  }

  void _showConnectionRequestDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const SizedBox(height: 16),
              Text(
                'Would you like to accept this connection request?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connection request declined')),
                );
              },
              child: const Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connection request accepted!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'reminder':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: InkWell(
        onTap: () => _handleNotificationAction(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _getTimeAgo(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        if (notification.actionData != null)
                          Text(
                            'Tap to view',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      if (!notification.isRead) {
                        _markAsRead(notification);
                      }
                      break;
                    case 'delete':
                      _deleteNotification(notification);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read),
                          SizedBox(width: 8),
                          Text('Mark as read'),
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
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
                  const Text('All'),
                  if (_allNotifications.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _allNotifications.length.toString(),
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
                  const Text('Unread'),
                  if (_unreadNotifications.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _unreadNotifications.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_unreadNotifications.isNotEmpty)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.mark_email_read),
              tooltip: 'Mark all as read',
            ),
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All notifications
                _allNotifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _allNotifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(_allNotifications[index]);
                          },
                        ),
                      ),
                
                // Unread notifications
                _unreadNotifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mark_email_read,
                              size: 64,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'All caught up!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No unread notifications',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _unreadNotifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(_unreadNotifications[index]);
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
