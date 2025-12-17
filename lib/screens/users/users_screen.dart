import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await ApiService.getUsers();

      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            (user.companyName?.toLowerCase().contains(query) ?? false);

        final matchesFilter = _selectedFilter == 'Tümü' ||
            (_selectedFilter == 'Müteahhitler' && user.isContractor) ||
            (_selectedFilter == 'Kullanıcılar' && !user.isContractor) ||
            (_selectedFilter == 'Onaylı' && user.isVerified) ||
            (_selectedFilter == 'Banlı' && user.isBanned);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _banUser(User user) async {
    final reason = await _showBanDialog();
    if (reason == null) return;

    try {
      await ApiService.banUser(
        user.id!,
        reason,
        AuthService.currentUser?.email ?? 'admin',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} başarıyla banlandı'),
          backgroundColor: Colors.green,
        ),
      );

      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyContractor(User user) async {
    try {
      await ApiService.verifyContractor(user.id!, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} müteahhit olarak onaylandı'),
          backgroundColor: Colors.green,
        ),
      );

      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showBanDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kullanıcıyı Banla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ban sebebini belirtin:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ban sebebi...',
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
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Banla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcılar'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtre
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Kullanıcı ara...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Tümü',
                      'Müteahhitler',
                      'Kullanıcılar',
                      'Onaylı',
                      'Banlı',
                    ].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            _filterUsers();
                          },
                          selectedColor: Color(0xFF4361ee).withOpacity(0.2),
                          checkmarkColor: Color(0xFF4361ee),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Kullanıcı Listesi
          Expanded(
            child: _isLoading
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
                              onPressed: _loadUsers,
                              child: Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Kullanıcı bulunamadı',
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
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    // EvAtlas Admin'i gizle
    final isEvAtlasAdmin = user.email == 'admin@evatlas.com';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isEvAtlasAdmin
                      ? Colors.purple
                      : (user.isContractor ? Colors.orange : Colors.blue),
                  child: Icon(
                    isEvAtlasAdmin
                        ? Icons.admin_panel_settings
                        : (user.isContractor ? Icons.business : Icons.person),
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
                          if (user.isVerified)
                            Icon(Icons.verified, color: Colors.green, size: 20),
                          if (user.isBanned)
                            Icon(Icons.block, color: Colors.red, size: 20),
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
                        Text(
                          user.companyName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Kullanıcı Bilgileri
            Row(
              children: [
                if (isEvAtlasAdmin)
                  _buildInfoChip('Platform Yöneticisi', Colors.purple)
                else
                  _buildInfoChip(
                    user.isContractor ? 'Müteahhit' : 'Kullanıcı',
                    user.isContractor ? Colors.orange : Colors.blue,
                  ),
                SizedBox(width: 8),
                if (user.isVerified) _buildInfoChip('Onaylı', Colors.green),
                if (user.isBanned) _buildInfoChip('Banlı', Colors.red),
              ],
            ),

            if (user.lastLoginAt != null) ...[
              SizedBox(height: 8),
              Text(
                'Son giriş: ${_formatDate(user.lastLoginAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            // Aksiyon Butonları
            if (!isEvAtlasAdmin) ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showUserDetails(user),
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Detaylar'),
                  ),
                  if (user.isContractor && !user.isVerified)
                    TextButton.icon(
                      onPressed: () => _verifyContractor(user),
                      icon: Icon(Icons.verified, size: 16, color: Colors.green),
                      label:
                          Text('Onayla', style: TextStyle(color: Colors.green)),
                    ),
                  if (!user.isBanned && user.id != AuthService.currentUser?.id)
                    TextButton.icon(
                      onPressed: () => _banUser(user),
                      icon: Icon(Icons.block, size: 16, color: Colors.red),
                      label: Text('Banla', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
              if (user.phone != null) _buildDetailRow('Telefon', user.phone!),
              if (user.companyName != null)
                _buildDetailRow('Şirket', user.companyName!),
              if (user.taxNumber != null)
                _buildDetailRow('Vergi No', user.taxNumber!),
              if (user.businessNumber != null)
                _buildDetailRow('İş No', user.businessNumber!),
              _buildDetailRow('Kayıt Tarihi', _formatDate(user.createdAt)),
              if (user.lastLoginAt != null)
                _buildDetailRow('Son Giriş', _formatDate(user.lastLoginAt!)),
              if (user.lastIpAddress != null)
                _buildDetailRow('Son IP', user.lastIpAddress!),
              _buildDetailRow('Durum', user.isActive ? 'Aktif' : 'Pasif'),
              if (user.isBanned) ...[
                _buildDetailRow(
                    'Ban Sebebi', user.banReason ?? 'Belirtilmemiş'),
                if (user.bannedAt != null)
                  _buildDetailRow('Ban Tarihi', _formatDate(user.bannedAt!)),
                if (user.bannedBy != null)
                  _buildDetailRow('Banlayan', user.bannedBy!),
              ],
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
