import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class BannedUsersScreen extends StatefulWidget {
  @override
  _BannedUsersScreenState createState() => _BannedUsersScreenState();
}

class _BannedUsersScreenState extends State<BannedUsersScreen> {
  List<User> _bannedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBannedUsers();
  }

  Future<void> _loadBannedUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await ApiService.getBannedUsers();

      setState(() {
        _bannedUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _unbanUser(User user) async {
    final confirmed = await _showUnbanDialog(user);
    if (!confirmed) return;

    try {
      await ApiService.unbanUser(
        user.id!,
        AuthService.currentUser?.email ?? 'admin',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} banı kaldırıldı'),
          backgroundColor: Colors.green,
        ),
      );

      _loadBannedUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showUnbanDialog(User user) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Banı Kaldır'),
        content: Text('${user.name} kullanıcısının banını kaldırmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Banı Kaldır'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banlı Kullanıcılar'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBannedUsers,
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
                        onPressed: _loadBannedUsers,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _bannedUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'Banlı kullanıcı yok',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tüm kullanıcılar aktif durumda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _bannedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _bannedUsers[index];
                        return _buildBannedUserCard(user);
                      },
                    ),
    );
  }

  Widget _buildBannedUserCard(User user) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kullanıcı Bilgileri
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.block,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Text(
                                'BANLI',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (user.companyName != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.business, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                user.companyName!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Ban Bilgileri
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Ban Detayları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (user.banReason != null) ...[
                      Text(
                        'Sebep: ${user.banReason}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    if (user.bannedAt != null) ...[
                      Text(
                        'Ban Tarihi: ${_formatDate(user.bannedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    if (user.bannedBy != null) ...[
                      Text(
                        'Banlayan: ${user.bannedBy}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Kullanıcı Türü
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isContractor ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user.isContractor ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      user.isContractor ? 'Müteahhit' : 'Kullanıcı',
                      style: TextStyle(
                        color: user.isContractor ? Colors.orange : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (user.isVerified) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Onaylı',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 16),

              // Aksiyon Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showUserDetails(user),
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Detaylar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _unbanUser(user),
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Banı Kaldır'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kullanıcı Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Ad', user.name),
              _buildDetailRow('E-posta', user.email),
              if (user.phone != null)
                _buildDetailRow('Telefon', user.phone!),
              if (user.companyName != null)
                _buildDetailRow('Şirket', user.companyName!),
              if (user.taxNumber != null)
                _buildDetailRow('Vergi No', user.taxNumber!),
              if (user.businessNumber != null)
                _buildDetailRow('İş No', user.businessNumber!),
              _buildDetailRow('Tip', user.isContractor ? 'Müteahhit' : 'Kullanıcı'),
              _buildDetailRow('Onaylı', user.isVerified ? 'Evet' : 'Hayır'),
              _buildDetailRow('Kayıt Tarihi', _formatDate(user.createdAt)),
              if (user.lastLoginAt != null)
                _buildDetailRow('Son Giriş', _formatDate(user.lastLoginAt!)),
              if (user.lastIpAddress != null)
                _buildDetailRow('Son IP', user.lastIpAddress!),
              Divider(),
              Text(
                'Ban Bilgileri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Ban Sebebi', user.banReason ?? 'Belirtilmemiş'),
              if (user.bannedAt != null)
                _buildDetailRow('Ban Tarihi', _formatDate(user.bannedAt!)),
              if (user.bannedBy != null)
                _buildDetailRow('Banlayan', user.bannedBy!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}