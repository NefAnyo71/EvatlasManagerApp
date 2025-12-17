import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManagerNotificationService {
  // ignore: unused_field
  static const String _baseUrl = 'http://192.168.1.103:5238/api';

  // Manager bildirimlerini al
  static Future<List<AdminNotification>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson =
          prefs.getStringList('admin_notifications') ?? [];

      return notificationsJson
          .map((json) => AdminNotification.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList(); // En yeni üstte
    } catch (e) {
      print('Bildirimler alınırken hata: $e');
      return [];
    }
  }

  // Güvenlik uyarısı var mı kontrol et
  static Future<bool> hasSecurityAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_security_alert') ?? false;
  }

  // Son güvenlik uyarısını al
  static Future<SecurityAlert?> getLastSecurityAlert() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertJson = prefs.getString('last_security_alert');

      if (alertJson != null) {
        return SecurityAlert.fromJson(jsonDecode(alertJson));
      }
      return null;
    } catch (e) {
      print('Güvenlik uyarısı alınırken hata: $e');
      return null;
    }
  }

  // Güvenlik uyarısını temizle
  static Future<void> clearSecurityAlert() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_security_alert');
    await prefs.remove('last_security_alert');
  }

  // Sistem güncelleme bilgisini al
  static Future<SystemUpdate?> getSystemUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updateJson = prefs.getString('system_update_info');

      if (updateJson != null) {
        return SystemUpdate.fromJson(jsonDecode(updateJson));
      }
      return null;
    } catch (e) {
      print('Sistem güncellemesi alınırken hata: $e');
      return null;
    }
  }

  // Sistem güncelleme bilgisini temizle
  static Future<void> clearSystemUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('system_update_info');
  }



  // Bildirimleri temizle
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_notifications');
  }

  // Okunmamış bildirim sayısını al
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReadTime = prefs.getInt('last_notification_read_time') ?? 0;

      final notifications = await getNotifications();
      return notifications
          .where((n) => n.timestamp.millisecondsSinceEpoch > lastReadTime)
          .length;
    } catch (e) {
      print('Okunmamış bildirim sayısı alınırken hata: $e');
      return 0;
    }
  }

  // Bildirimleri okundu olarak işaretle
  static Future<void> markAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'last_notification_read_time', DateTime.now().millisecondsSinceEpoch);
  }
}

class AdminNotification {
  final String type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, String> data;

  AdminNotification({
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.data,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      data: Map<String, String>.from(json['data'] ?? {}),
    );
  }
}

class SecurityAlert {
  final String type;
  final String severity;
  final String message;
  final DateTime timestamp;

  SecurityAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
  });

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'medium',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SystemUpdate {
  final String type;
  final String version;
  final String message;
  final DateTime timestamp;

  SystemUpdate({
    required this.type,
    required this.version,
    required this.message,
    required this.timestamp,
  });

  factory SystemUpdate.fromJson(Map<String, dynamic> json) {
    return SystemUpdate(
      type: json['type'] ?? '',
      version: json['version'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
