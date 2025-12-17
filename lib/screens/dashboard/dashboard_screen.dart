import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stats = await ApiService.getDashboardStats();

      setState(() {
        _stats = stats;
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
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
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
                        onPressed: _loadDashboardData,
                        child: Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hoş geldin mesajı
                      _buildWelcomeCard(),
                      SizedBox(height: 24),

                      // Ana istatistikler
                      _buildMainStats(),
                      SizedBox(height: 24),

                      // Hızlı erişim butonları
                      _buildQuickActions(),
                      SizedBox(height: 24),

                      // Detaylı istatistikler
                      _buildDetailedStats(),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeCard() {
    final user = AuthService.currentUser;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş geldin,',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            user?.name ?? 'Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.companyName ?? 'EvAtlas Manager',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    if (_stats == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel İstatistikler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2d3748),
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Toplam Kullanıcı',
              _stats!['totalUsers'].toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Toplam İlan',
              _stats!['totalProperties'].toString(),
              Icons.home,
              Colors.green,
            ),
            _buildStatCard(
              'Müteahhitler',
              _stats!['contractors'].toString(),
              Icons.business,
              Colors.orange,
            ),
            _buildStatCard(
              'Onaylı Müteahhitler',
              _stats!['verifiedContractors'].toString(),
              Icons.verified,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2d3748),
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Kullanıcılar',
                Icons.people,
                Colors.blue,
                () => Navigator.pushNamed(context, '/users'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'İlanlar',
                Icons.home,
                Colors.green,
                () => Navigator.pushNamed(context, '/properties'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Banlı Kullanıcılar',
                Icons.block,
                Colors.red,
                () => Navigator.pushNamed(context, '/banned-users'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Şikayetler',
                Icons.report,
                Colors.orange,
                () => Navigator.pushNamed(context, '/reports'),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Mesajlaşma',
                Icons.message,
                Colors.purple,
                () => Navigator.pushNamed(context, '/messages'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Güvenlik',
                Icons.security,
                Colors.red,
                () => Navigator.pushNamed(context, '/security'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    if (_stats == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı İstatistikler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2d3748),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Son 7 Gün',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWeeklyStat(
                      'Yeni Kullanıcılar',
                      _stats!['newUsersLast7Days'].toString(),
                      Icons.person_add,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildWeeklyStat(
                      'Yeni İlanlar',
                      _stats!['newPropertiesLast7Days'].toString(),
                      Icons.add_home,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStat(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', true, () {}),
          _buildNavItem(Icons.people, 'Kullanıcılar', false, () {
            Navigator.pushNamed(context, '/users');
          }),
          _buildNavItem(Icons.home, 'İlanlar', false, () {
            Navigator.pushNamed(context, '/properties');
          }),
          _buildNavItem(Icons.speed, 'Rate Limit', false, () {
            Navigator.pushNamed(context, '/rate-limit');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
