import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String channelId = 'classapp_notifications';
  static const String channelName = 'ClassApp Notifications';
  static const String channelDescription = 'Notifications for ClassApp';

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 33) {
        final status = await Permission.notification.request();
        return status == PermissionStatus.granted;
      }
      return true; // Android versions below 13 don't need explicit permission
    } else if (Platform.isIOS) {
      final granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return false;
  }

  Future<int> _getAndroidVersion() async {
    // This is a simplified version - in a real app you'd use device_info_plus
    return 33; // Assuming Android 13+
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate to appropriate screen
    // This would be implemented based on your app's navigation structure
    try {
      final parts = payload.split('|');
      final type = parts[0];

      switch (type) {
        case 'assessment':
          // Navigate to assessment
          break;
        case 'event':
          // Navigate to event
          break;
        case 'job':
          // Navigate to job
          break;
        case 'connection':
          // Navigate to connections
          break;
        default:
          // Navigate to notifications center
          break;
      }
    } catch (e) {
      // Error handling notification payload: $e
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: _getNotificationIcon(type),
      color: _getNotificationColor(type),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: _getNotificationIcon(type),
      color: _getNotificationColor(type),
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.assessment:
        return '@drawable/ic_assessment';
      case NotificationType.event:
        return '@drawable/ic_event';
      case NotificationType.job:
        return '@drawable/ic_job';
      case NotificationType.connection:
        return '@drawable/ic_connection';
      case NotificationType.message:
        return '@drawable/ic_message';
      default:
        return '@mipmap/ic_launcher';
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.assessment:
        return Colors.purple;
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.job:
        return Colors.green;
      case NotificationType.connection:
        return Colors.orange;
      case NotificationType.message:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Predefined notification methods for common scenarios
  Future<void> showAssessmentReminder({
    required String assessmentTitle,
    required DateTime dueDate,
    required String assessmentId,
  }) async {
    final timeUntilDue = dueDate.difference(DateTime.now());
    
    if (timeUntilDue.inHours > 0) {
      await showNotification(
        id: assessmentId.hashCode,
        title: 'Assessment Due Soon',
        body: '$assessmentTitle is due in ${timeUntilDue.inHours} hours',
        payload: 'assessment|$assessmentId',
        type: NotificationType.assessment,
      );
    }
  }

  Future<void> showEventReminder({
    required String eventTitle,
    required DateTime eventDate,
    required String eventId,
  }) async {
    await showScheduledNotification(
      id: eventId.hashCode,
      title: 'Upcoming Event',
      body: '$eventTitle starts soon',
      scheduledTime: eventDate.subtract(const Duration(hours: 1)),
      payload: 'event|$eventId',
      type: NotificationType.event,
    );
  }

  Future<void> showJobAlert({
    required String jobTitle,
    required String company,
    required String jobId,
  }) async {
    await showNotification(
      id: jobId.hashCode,
      title: 'New Job Opportunity',
      body: '$jobTitle at $company',
      payload: 'job|$jobId',
      type: NotificationType.job,
    );
  }

  Future<void> showConnectionRequest({
    required String senderName,
    required String connectionId,
  }) async {
    await showNotification(
      id: connectionId.hashCode,
      title: 'New Connection Request',
      body: '$senderName wants to connect with you',
      payload: 'connection|$connectionId',
      type: NotificationType.connection,
    );
  }

  Future<void> showNewMessage({
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await showNotification(
      id: chatId.hashCode,
      title: 'New Message from $senderName',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      payload: 'message|$chatId',
      type: NotificationType.message,
    );
  }

  Future<void> showAssessmentGraded({
    required String assessmentTitle,
    required int score,
    required String assessmentId,
  }) async {
    await showNotification(
      id: 'graded_$assessmentId'.hashCode,
      title: 'Assessment Graded',
      body: 'You scored $score% on $assessmentTitle',
      payload: 'assessment|$assessmentId',
      type: NotificationType.assessment,
    );
  }

  Future<void> showEventApproved({
    required String eventTitle,
    required String eventId,
  }) async {
    await showNotification(
      id: 'approved_$eventId'.hashCode,
      title: 'Event Approved',
      body: 'Your event "$eventTitle" has been approved',
      payload: 'event|$eventId',
      type: NotificationType.event,
    );
  }

  Future<void> showApplicationUpdate({
    required String jobTitle,
    required String status,
    required String applicationId,
  }) async {
    await showNotification(
      id: 'app_$applicationId'.hashCode,
      title: 'Application Update',
      body: 'Your application for $jobTitle is now $status',
      payload: 'job|$applicationId',
      type: NotificationType.job,
    );
  }
}

enum NotificationType {
  general,
  assessment,
  event,
  job,
  connection,
  message,
}

// Widget for notification settings
class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _assessmentReminders = true;
  bool _eventReminders = true;
  bool _jobAlerts = true;
  bool _connectionRequests = true;
  bool _messageNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load notification settings from shared preferences
    // This is a placeholder - implement with actual storage
    setState(() {
      _notificationsEnabled = true;
      _assessmentReminders = true;
      _eventReminders = true;
      _jobAlerts = true;
      _connectionRequests = true;
      _messageNotifications = true;
    });
  }

  Future<void> _saveSettings() async {
    // Save notification settings to shared preferences
    // This is a placeholder - implement with actual storage
  }

  Future<void> _testNotification() async {
    await _notificationService.showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from ClassApp',
      type: NotificationType.general,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _testNotification,
            child: const Text(
              'Test',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                if (value) {
                  final granted = await _notificationService.requestPermissions();
                  if (!granted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notifications in device settings'),
                      ),
                    );
                    return;
                  }
                }
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ),
          
          if (_notificationsEnabled) ...[
            const SizedBox(height: 16),
            Text(
              'Notification Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: SwitchListTile(
                title: const Text('Assessment Reminders'),
                subtitle: const Text('Get reminded about upcoming assessments'),
                value: _assessmentReminders,
                onChanged: (value) {
                  setState(() {
                    _assessmentReminders = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            
            Card(
              child: SwitchListTile(
                title: const Text('Event Reminders'),
                subtitle: const Text('Get reminded about upcoming events'),
                value: _eventReminders,
                onChanged: (value) {
                  setState(() {
                    _eventReminders = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            
            Card(
              child: SwitchListTile(
                title: const Text('Job Alerts'),
                subtitle: const Text('Get notified about new job opportunities'),
                value: _jobAlerts,
                onChanged: (value) {
                  setState(() {
                    _jobAlerts = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            
            Card(
              child: SwitchListTile(
                title: const Text('Connection Requests'),
                subtitle: const Text('Get notified about connection requests'),
                value: _connectionRequests,
                onChanged: (value) {
                  setState(() {
                    _connectionRequests = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            
            Card(
              child: SwitchListTile(
                title: const Text('Messages'),
                subtitle: const Text('Get notified about new messages'),
                value: _messageNotifications,
                onChanged: (value) {
                  setState(() {
                    _messageNotifications = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Quiet Hours'),
                subtitle: const Text('Set times when notifications are muted'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to quiet hours settings
                },
              ),
            ),
            
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Clear All Notifications'),
                subtitle: const Text('Remove all pending notifications'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await _notificationService.cancelAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications cleared'),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
