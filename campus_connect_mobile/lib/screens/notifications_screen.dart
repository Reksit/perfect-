import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_extensions.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allNotifications = [];
  List<Map<String, dynamic>> _connectionNotifications = [];
  List<Map<String, dynamic>> _eventNotifications = [];
  List<Map<String, dynamic>> _systemNotifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      // Mock notifications data - replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));
      
      final notifications = [
        {
          'id': '1',
          'type': 'connection',
          'title': 'New Connection Request',
          'message': 'John Doe wants to connect with you',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
          'isRead': false,
          'avatar': null,
          'actionData': {'userId': 'user123', 'requestId': 'req123'},
        },
        {
          'id': '2',
          'type': 'event',
          'title': 'Event Reminder',
          'message': 'Tech Talk: AI in Education starts in 1 hour',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'isRead': false,
          'avatar': null,
          'actionData': {'eventId': 'event123'},
        },
        {
          'id': '3',
          'type': 'connection',
          'title': 'Connection Accepted',
          'message': 'Sarah Smith accepted your connection request',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': true,
          'avatar': null,
          'actionData': {'userId': 'user456'},
        },
        {
          'id': '4',
          'type': 'system',
          'title': 'Profile Updated',
          'message': 'Your profile has been successfully updated',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'isRead': true,
          'avatar': null,
          'actionData': {},
        },
        {
          'id': '5',
          'type': 'event',
          'title': 'New Event',
          'message': 'Alumni Networking Event has been scheduled',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': false,
          'avatar': null,
          'actionData': {'eventId': 'event456'},
        },
        {
          'id': '6',
          'type': 'connection',
          'title': 'Message Received',
          'message': 'You have a new message from Mike Johnson',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': false,
          'avatar': null,
          'actionData': {'userId': 'user789', 'messageId': 'msg123'},
        },
        {
          'id': '7',
          'type': 'system',
          'title': 'Security Alert',
          'message': 'New login detected from a different device',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': true,
          'avatar': null,
          'actionData': {},
        },
        {
          'id': '8',
          'type': 'event',
          'title': 'Event Cancelled',
          'message': 'Workshop: Flutter Development has been cancelled',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': true,
          'avatar': null,
          'actionData': {'eventId': 'event789'},
        },
      ];

      setState(() {
        _allNotifications = notifications;
        _connectionNotifications = notifications.where((n) => n['type'] == 'connection').toList();
        _eventNotifications = notifications.where((n) => n['type'] == 'event').toList();
        _systemNotifications = notifications.where((n) => n['type'] == 'system').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      // TODO: Implement API call to mark notification as read
      setState(() {
        for (var notification in _allNotifications) {
          if (notification['id'] == notificationId) {
            notification['isRead'] = true;
            break;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // TODO: Implement API call to mark all notifications as read
      setState(() {
        for (var notification in _allNotifications) {
          notification['isRead'] = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking all as read: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      // TODO: Implement API call to delete notification
      setState(() {
        _allNotifications.removeWhere((n) => n['id'] == notificationId);
        _connectionNotifications.removeWhere((n) => n['id'] == notificationId);
        _eventNotifications.removeWhere((n) => n['id'] == notificationId);
        _systemNotifications.removeWhere((n) => n['id'] == notificationId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    _markAsRead(notification['id']);
    
    final type = notification['type'];
    final actionData = notification['actionData'] as Map<String, dynamic>;

    switch (type) {
      case 'connection':
        if (actionData.containsKey('requestId')) {
          _showConnectionRequestDialog(notification);
        } else if (actionData.containsKey('messageId')) {
          _navigateToMessages(actionData['userId']);
        } else {
          _navigateToProfile(actionData['userId']);
        }
        break;
      case 'event':
        _navigateToEvent(actionData['eventId']);
        break;
      case 'system':
        _showSystemNotificationDialog(notification);
        break;
    }
  }

  void _showConnectionRequestDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Request'),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () {
              _rejectConnectionRequest(notification['actionData']['requestId']);
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              _acceptConnectionRequest(notification['actionData']['requestId']);
              Navigator.pop(context);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showSystemNotificationDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Text(notification['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.acceptConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection request accepted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: $e')),
      );
    }
  }

  Future<void> _rejectConnectionRequest(String requestId) async {
    try {
      await ConnectionAPI.rejectConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection request rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting request: $e')),
      );
    }
  }

  void _navigateToProfile(String userId) {
    // TODO: Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to profile')),
    );
  }

  void _navigateToMessages(String userId) {
    // TODO: Navigate to messages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to messages')),
    );
  }

  void _navigateToEvent(String eventId) {
    // TODO: Navigate to event details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to event')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading notifications...'),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${_allNotifications.length})'),
            Tab(text: 'Connections (${_connectionNotifications.length})'),
            Tab(text: 'Events (${_eventNotifications.length})'),
            Tab(text: 'System (${_systemNotifications.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(_allNotifications),
          _buildNotificationsList(_connectionNotifications),
          _buildNotificationsList(_eventNotifications),
          _buildNotificationsList(_systemNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    final timeAgo = _getTimeAgo(timestamp);

    return Dismissible(
      key: Key(notification['id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Container(
        color: isRead ? null : Colors.blue.withOpacity(0.1),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification['type']),
            child: Icon(
              _getNotificationIcon(notification['type']),
              color: Colors.white,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message']),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: !isRead
              ? const Icon(Icons.circle, color: Colors.blue, size: 12)
              : null,
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'connection':
        return Icons.people;
      case 'event':
        return Icons.event;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'connection':
        return Colors.blue;
      case 'event':
        return Colors.green;
      case 'system':
        return Colors.orange;
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _allNotifications.clear();
                _connectionNotifications.clear();
                _eventNotifications.clear();
                _systemNotifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
