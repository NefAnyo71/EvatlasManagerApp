import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RateLimitScreen extends StatefulWidget {
  @override
  _RateLimitScreenState createState() => _RateLimitScreenState();
}

class _RateLimitScreenState extends State<RateLimitScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _rateLimitLogs = [];
  List<Map<String, dynamic>> _activeUsers = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ApiService.getRateLimitData();
      
      setState(() {
        _rateLimitLogs = List<Map<String, dynamic>>.from(data['rateLimitLogs'] ?? []);
        _activeUsers = List<Map<String, dynamic>>.from(data['activeUsers'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Limit İzleme'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tümünü Temizle'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Rate Limit Logları'),
            Tab(text: 'Aktif Kullanıcılar'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Hata: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRateLimitLogs(),
                    _buildActiveUsers(),
                  ],
                ),
    );
  }

  Widget _buildRateLimitLogs() {
    if (_rateLimitLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Rate limit ihlali yok', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _rateLimitLogs.length,
      itemBuilder: (context, index) {
        final log = _rateLimitLogs[index];
        return _buildRateLimitCard(log);
      },
    );
  }

  Widget _buildActiveUsers() {
    if (_activeUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aktif kullanıcı yok', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _activeUsers.length,
      itemBuilder: (context, index) {
        final user = _activeUsers[index];
        return _buildActiveUserCard(user);
      },
    );
  }

  Widget _buildRateLimitCard(Map<String, dynamic> log) {
    final isBlocked = log['isBlocked'] ?? false;
    final severity = log['severity'] ?? 'medium';
    
    Color cardColor = Colors.orange;
    IconData cardIcon = Icons.warning;
    
    if (isBlocked) {
      cardColor = Colors.red;
      cardIcon = Icons.block;
    } else if (severity == 'high') {
      cardColor = Colors.red;
      cardIcon = Icons.error;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cardIcon, color: cardColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['clientId'] ?? 'Bilinmeyen IP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          log['endpoint'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isBlocked ? 'BLOKLU' : 'UYARI',
                          style: TextStyle(
                            color: cardColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _clearSingleRateLimit(log['clientId']),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogDetail('İstek Sayısı', '${log['requestCount']}/${log['maxRequests']}'),
                    _buildLogDetail('User Agent', log['userAgent'] ?? 'Bilinmiyor'),
                    _buildLogDetail('Zaman', _formatDateTime(log['timestamp'])),
                    if (log['banUntil'] != null)
                      _buildLogDetail('Ban Bitiş', _formatDateTime(log['banUntil'])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUserCard(Map<String, dynamic> user) {
    final isFlutter = user['isFlutterApp'] ?? false;
    final requestCount = user['requestCount'] ?? 0;
    final isLoggedIn = user['isLoggedIn'] ?? false;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isLoggedIn ? Colors.green : Colors.grey,
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['clientId'] ?? 'Bilinmeyen IP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user['userName'] != null)
                        Text(
                          user['userName'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (isFlutter)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Flutter',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLoggedIn ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLoggedIn ? 'GİRİŞ YAPMIŞ' : 'MİSAFİR',
                        style: TextStyle(
                          color: isLoggedIn ? Colors.green : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildUserStat('İstek Sayısı', requestCount.toString(), Icons.api),
                ),
                Expanded(
                  child: _buildUserStat('Son Aktivite', _formatTime(user['lastActivity']), Icons.access_time),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    try {
      final date = DateTime.parse(timestamp.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp.toString();
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Bilinmiyor';
    try {
      final date = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Az önce';
      if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
      if (diff.inHours < 24) return '${diff.inHours}sa önce';
      return '${diff.inDays}g önce';
    } catch (e) {
      return 'Bilinmiyor';
    }
  }

  Future<void> _showClearAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tüm Rate Limitleri Temizle'),
        content: Text('Tüm rate limit kayıtlarını temizlemek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Temizle'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _clearAllRateLimits();
    }
  }

  Future<void> _clearAllRateLimits() async {
    try {
      await ApiService.clearAllRateLimits();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tüm rate limitler temizlendi'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearSingleRateLimit(String clientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Limit Temizle'),
        content: Text('$clientId IP adresinin rate limit kayıtlarını temizlemek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Temizle'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    try {
      await ApiService.clearRateLimit(clientId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$clientId rate limiti temizlendi'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}