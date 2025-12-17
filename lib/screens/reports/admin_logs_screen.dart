import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminLogsScreen extends StatefulWidget {
  @override
  _AdminLogsScreenState createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await ApiService.getAdminLogs(page: _currentPage);

      setState(() {
        _logs = response['logs'];
        _totalPages = response['totalPages'];
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
        title: Text('Admin İşlem Logları'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLogs,
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
                        onPressed: _loadLogs,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _logs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Henüz log kaydı yok',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return _buildLogCard(log);
                              },
                            ),
                    ),
                    if (_totalPages > 1) _buildPagination(),
                  ],
                ),
    );
  }

  Widget _buildLogCard(dynamic log) {
    final actionColor = _getActionColor(log['action']);
    final actionIcon = _getActionIcon(log['action']);
    final actionText = _getActionText(log['action']);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: actionColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aksiyon Başlığı
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(actionIcon, color: actionColor, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                        Text(
                          'Admin: ${log['adminEmail']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(DateTime.parse(log['createdAt'])),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Detaylar
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (log['targetUserName'] != null) ...[
                      _buildDetailRow('Hedef Kullanıcı', log['targetUserName']),
                    ],
                    if (log['propertyTitle'] != null) ...[
                      _buildDetailRow('İlan', log['propertyTitle']),
                    ],
                    if (log['reason'] != null) ...[
                      _buildDetailRow('Sebep', log['reason']),
                    ],
                    if (log['details'] != null) ...[
                      _buildDetailRow('Detaylar', log['details']),
                    ],
                    if (log['ipAddress'] != null) ...[
                      _buildDetailRow('IP Adresi', log['ipAddress']),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadLogs();
                  }
                : null,
            child: Text('Önceki'),
          ),
          Text(
            'Sayfa $_currentPage / $_totalPages',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadLogs();
                  }
                : null,
            child: Text('Sonraki'),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'BAN_USER':
        return Colors.red;
      case 'UNBAN_USER':
        return Colors.green;
      case 'DELETE_PROPERTY':
        return Colors.orange;
      case 'RESOLVE_REPORT':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'BAN_USER':
        return Icons.block;
      case 'UNBAN_USER':
        return Icons.check_circle;
      case 'DELETE_PROPERTY':
        return Icons.delete;
      case 'RESOLVE_REPORT':
        return Icons.check;
      default:
        return Icons.info;
    }
  }

  String _getActionText(String action) {
    switch (action) {
      case 'BAN_USER':
        return 'Kullanıcı Engellendi';
      case 'UNBAN_USER':
        return 'Kullanıcı Engeli Kaldırıldı';
      case 'DELETE_PROPERTY':
        return 'İlan Silindi';
      case 'RESOLVE_REPORT':
        return 'Şikayet Çözüldü';
      default:
        return action;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}