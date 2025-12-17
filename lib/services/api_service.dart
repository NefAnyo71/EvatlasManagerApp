import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/property.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.103:5238';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['user']['isContractor'] == true) {
          return data;
        } else {
          throw Exception('Bu uygulama sadece yöneticiler içindir');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Giriş başarısız');
      }
    } catch (e) {
      throw Exception('Giriş hatası: $e');
    }
  }

  static Future<void> banUser(
      int userId, String reason, String bannedBy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/ban-user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reason': reason,
          'bannedBy': bannedBy,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Kullanıcı banlanamadı');
      }
    } catch (e) {
      throw Exception('Ban hatası: $e');
    }
  }

  static Future<void> unbanUser(int userId, String unbannedBy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/unban-user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'unbannedBy': unbannedBy,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Kullanıcı ban kaldırılamadı');
      }
    } catch (e) {
      throw Exception('Unban hatası: $e');
    }
  }

  static Future<List<User>> getBannedUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/banned-users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Banlı kullanıcılar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Banlı kullanıcılar hatası: $e');
    }
  }

  static Future<void> verifyContractor(int userId, bool isVerified) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/verify-contractor/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'isVerified': isVerified,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Müteahhit onaylanamadı');
      }
    } catch (e) {
      throw Exception('Müteahhit onay hatası: $e');
    }
  }

  static Future<List<dynamic>> getPropertyReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/property-reports'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('İlan şikayetleri yüklenemedi');
      }
    } catch (e) {
      throw Exception('İlan şikayetleri hatası: $e');
    }
  }

  static Future<void> resolveReport(
      int reportId, String resolvedBy, String? adminNotes) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/resolve-report/$reportId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'resolvedBy': resolvedBy,
          'adminNotes': adminNotes,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Şikayet çözülemedi');
      }
    } catch (e) {
      throw Exception('Şikayet çözüm hatası: $e');
    }
  }

  static Future<User> getUserActivity(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/user-activity/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Kullanıcı aktivitesi yüklenemedi');
      }
    } catch (e) {
      throw Exception('Kullanıcı aktivite hatası: $e');
    }
  }

  // Dashboard endpoints
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Dashboard istatistikleri yüklenemedi');
      }
    } catch (e) {
      throw Exception('Dashboard istatistik hatası: $e');
    }
  }

  // Properties endpoints
  static Future<List<Property>> getProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/properties'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('İlanlar yüklenemedi');
      }
    } catch (e) {
      throw Exception('İlanlar hatası: $e');
    }
  }

  static Future<void> deleteProperty(int propertyId, int userId,
      {String? adminEmail}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (adminEmail != null) {
        headers['Admin-Email'] = adminEmail;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/properties/$propertyId?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('İlan silinemedi');
      }
    } catch (e) {
      throw Exception('İlan silme hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> getAdminLogs(
      {int page = 1, int pageSize = 50}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/admin/admin-logs?page=$page&pageSize=$pageSize'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Admin logları yüklenemedi');
      }
    } catch (e) {
      throw Exception('Admin log hatası: $e');
    }
  }

  // Users endpoints - Demo data
  static Future<void> clearAllRateLimits() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/clear-all-rate-limits'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Tüm rate limitler temizlenemedi');
      }
    } catch (e) {
      throw Exception('Rate limit temizleme hatası: $e');
    }
  }

  static Future<void> clearRateLimit(String clientId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/admin/clear-rate-limit'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'clientId': clientId}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Rate limit temizlenemedi');
      }
    } catch (e) {
      throw Exception('Rate limit temizleme hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> getRateLimitData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/rate-limit-data'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Rate limit verileri yüklenemedi (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Rate limit veri hatası: $e');
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Kullanıcılar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Kullanıcılar hatası: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/security-logs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Güvenlik logları yüklenemedi');
      }
    } catch (e) {
      throw Exception('Güvenlik log hatası: $e');
    }
  }

  static Future<void> adminUpdateProperty(
      int propertyId, Map<String, dynamic> data, String adminEmail) async {
    try {
      final request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/api/properties/$propertyId'));

      request.headers.addAll({
        'Admin-Email': adminEmail,
      });

      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('İlan güncellenemedi');
      }
    } catch (e) {
      throw Exception('Admin update hatası: $e');
    }
  }

  static Future<void> sendWarning(
      int userId, String title, String message, String senderEmail) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/send-warning/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'message': message,
          'senderEmail': senderEmail,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Uyarı gönderilemedi');
      }
    } catch (e) {
      throw Exception('Uyarı gönderme hatası: $e');
    }
  }

  // Messages API methods
  static Future<Map<String, dynamic>> getConversations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/conversations/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Konuşmalar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Konuşmalar hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> getMessages(
      int currentUserId, int otherUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/$currentUserId/$otherUserId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Mesajlar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Mesajlar hatası: $e');
    }
  }

  static Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
    String? messageType,
    int? propertyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'messageType': messageType ?? 'text',
          'propertyId': propertyId,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Mesaj gönderilemedi');
      }
    } catch (e) {
      throw Exception('Mesaj gönderme hatası: $e');
    }
  }

  static Future<void> deleteConversation(
      int currentUserId, int otherUserId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/messages/conversation/$currentUserId/$otherUserId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Konuşma silinemedi');
      }
    } catch (e) {
      throw Exception('Konuşma silme hatası: $e');
    }
  }
}
