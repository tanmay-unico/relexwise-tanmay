import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/api/services.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await apiService.getNotifications();
      _notifications = list;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });

    try {
      await apiService.deleteNotification(notificationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notification')),
        );
        _loadNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final String title = notification['title']?.toString() ?? '';
    final String body = notification['body']?.toString() ?? '';
    final dynamic createdAtRaw = notification['createdAt'];
    final DateTime createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
        : (createdAtRaw is DateTime ? createdAtRaw : DateTime.now());
    final bool isRead = notification['isRead'] == true;
    return Slidable(
      key: ValueKey<String>(notification['id']?.toString() ?? ''),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          _deleteNotification(notification['id']);
        }),
        children: const [],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: isRead ? Colors.white : Colors.blue[50],
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(body),
              const SizedBox(height: 4),
              Text(
                _formatTime(createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            // TODO: Handle notification tap
          },
        ),
      ),
    );
  }
}

