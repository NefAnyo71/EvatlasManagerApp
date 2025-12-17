import 'package:flutter/material.dart';
import '../services/manager_notification_service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final Color badgeColor;
  final double badgeSize;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.badgeColor = Colors.red,
    this.badgeSize = 16.0,
  }) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;
  bool _hasSecurityAlert = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationData();
  }

  Future<void> _loadNotificationData() async {
    final unreadCount = await ManagerNotificationService.getUnreadCount();
    final hasSecurityAlert =
        await ManagerNotificationService.hasSecurityAlert();

    if (mounted) {
      setState(() {
        _unreadCount = unreadCount;
        _hasSecurityAlert = hasSecurityAlert;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_unreadCount > 0 || _hasSecurityAlert)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              width: widget.badgeSize,
              height: widget.badgeSize,
              decoration: BoxDecoration(
                color: _hasSecurityAlert ? Colors.orange : widget.badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: _hasSecurityAlert
                    ? Icon(Icons.warning,
                        size: widget.badgeSize * 0.6, color: Colors.white)
                    : Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.badgeSize * 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
