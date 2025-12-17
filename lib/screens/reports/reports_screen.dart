import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'admin_logs_screen.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reports = await ApiService.getPropertyReports();

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveReport(dynamic report) async {
    final notes = await _showResolveDialog();
    
    try {
      await ApiService.resolveReport(
        report['id'],
        AuthService.currentUser?.email ?? 'admin',
        notes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Şikayet çözüldü'),
          backgroundColor: Colors.green,
        ),
      );

      _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showResolveDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Şikayeti Çöz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin notları (opsiyonel):'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Çözüm notları...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Çöz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlan Şikayetleri'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLogsScreen()),
              );
            },
            tooltip: 'Admin Logları',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReports,
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
                        onPressed: _loadReports,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'Bekleyen şikayet yok',
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
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return _buildReportCard(report);
                      },
                    ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    final property = report['property'];
    final owner = property['owner'];
    final reportedBy = report['reportedBy'];
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Şikayet Bilgisi
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.report, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Şikayet: ${report['reportReason']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    if (report['reportDetails'] != null) ...[
                      SizedBox(height: 8),
                      Text(
                        report['reportDetails'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    SizedBox(height: 8),
                    Text(
                      'Şikayet eden: ${reportedBy['name']} (${reportedBy['email']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Tarih: ${_formatDate(DateTime.parse(report['reportedAt']))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // İlan Bilgisi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İlan Resmi
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [Color(0xFF4361ee), Color(0xFF3f37c9)],
                      ),
                    ),
                    child: property['imageUrl'] != null && property['imageUrl'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'http://192.168.1.103:5238${property['imageUrl']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.home,
                                  color: Colors.white,
                                  size: 32,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // İlan Detayları
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          property['location'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          property['type'] == 'Kiralık'
                              ? '₺${property['price'].toStringAsFixed(0)}/ay'
                              : '₺${property['price'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4361ee),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Müteahhit Bilgisi
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'İlan Sahibi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('Ad: ${owner['name']}'),
                    Text('E-posta: ${owner['email']}'),
                    if (owner['companyName'] != null)
                      Text('Şirket: ${owner['companyName']}'),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Aksiyon Butonları
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _removeProperty(report),
                          icon: Icon(Icons.delete, size: 16),
                          label: Text('İlanı Kaldır'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _banUser(report),
                          icon: Icon(Icons.block, size: 16),
                          label: Text('Müteahhiti Engelle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _resolveReport(report),
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Şikayeti Çöz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeProperty(dynamic report) async {
    final confirmed = await _showConfirmDialog(
      'İlanı Kaldır',
      'Bu ilanı kalıcı olarak kaldırmak istediğinizden emin misiniz?',
      'Kaldır',
      Colors.red,
    );
    
    if (confirmed == true) {
      try {
        await ApiService.deleteProperty(
          report['property']['id'],
          report['property']['userId'],
          adminEmail: AuthService.currentUser?.email,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlan başarıyla kaldırıldı'),
            backgroundColor: Colors.green,
          ),
        );

        _loadReports();
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

  Future<void> _banUser(dynamic report) async {
    final reason = await _showBanDialog();
    
    if (reason != null && reason.isNotEmpty) {
      try {
        await ApiService.banUser(
          report['property']['owner']['id'],
          reason,
          AuthService.currentUser?.email ?? 'admin',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müteahhit başarıyla engellendi'),
            backgroundColor: Colors.green,
          ),
        );

        _loadReports();
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

  Future<bool?> _showConfirmDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Future<String?> _showBanDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Müteahhiti Engelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Engelleme sebebi:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Engelleme sebebini yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Engelle'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}