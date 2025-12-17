import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<Map<String, dynamic>> _securityLogs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSecurityLogs();
  }

  Future<void> _loadSecurityLogs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final logs = await ApiService.getSecurityLogs();
      
      setState(() {
        _securityLogs = logs;
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
        title: Text('Güvenlik Logları'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSecurityLogs,
          ),
        ],
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
                        onPressed: _loadSecurityLogs,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _securityLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text('Güvenlik tehdidi yok', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _securityLogs.length,
                      itemBuilder: (context, index) {
                        final log = _securityLogs[index];
                        return _buildSecurityCard(log);
                      },
                    ),
    );
  }

  Widget _buildSecurityCard(Map<String, dynamic> log) {
    final threatType = log['threatType'] ?? 'Unknown';
    final severity = log['severity'] ?? 'medium';
    
    Color cardColor = Colors.orange;
    IconData cardIcon = Icons.warning;
    
    switch (severity.toLowerCase()) {
      case 'critical':
        cardColor = Colors.red[800]!;
        cardIcon = Icons.dangerous;
        break;
      case 'high':
        cardColor = Colors.red;
        cardIcon = Icons.error;
        break;
      case 'medium':
        cardColor = Colors.orange;
        cardIcon = Icons.warning;
        break;
      case 'low':
        cardColor = Colors.yellow[700]!;
        cardIcon = Icons.info;
        break;
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
                          threatType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'IP: ${log['ipAddress'] ?? 'Bilinmiyor'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      severity.toUpperCase(),
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    _buildLogDetail('Saldırı Türü', log['attackType'] ?? 'Bilinmiyor'),
                    _buildLogDetail('Hedef Endpoint', log['endpoint'] ?? 'Bilinmiyor'),
                    _buildLogDetail('User Agent', log['userAgent'] ?? 'Bilinmiyor'),
                    _buildLogDetail('Zaman', _formatDateTime(log['timestamp'])),
                    if (log['payload'] != null)
                      _buildLogDetail('Zararlı İçerik', log['payload'], isCode: true),
                    if (log['blocked'] == true)
                      _buildLogDetail('Durum', 'ENGELLENDI', color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogDetail(String label, String value, {bool isCode = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
            child: Container(
              padding: isCode ? EdgeInsets.all(8) : EdgeInsets.zero,
              decoration: isCode ? BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ) : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: isCode ? 'monospace' : null,
                  color: color ?? (isCode ? Colors.red[800] : null),
                ),
              ),
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
}