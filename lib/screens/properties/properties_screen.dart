import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/property.dart';

class PropertiesScreen extends StatefulWidget {
  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _searchController.addListener(_filterProperties);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final properties = await ApiService.getProperties();
      print('🏠 Yüklenen ilan sayısı: ${properties.length}');

      setState(() {
        _properties = properties;
        _filteredProperties = properties;
        _isLoading = false;
      });

      // Yükleme sonrası filtreleme uygula
      _filterProperties();
    } catch (e) {
      print('❌ İlan yükleme hatası: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProperties() {
    if (_properties.isEmpty) {
      print('🔍 Properties listesi boş, filtreleme yapılamıyor');
      return;
    }

    final query = _searchController.text.toLowerCase();
    print(
        '🔍 Filtreleme - Query: "$query", Filter: $_selectedFilter, Total: ${_properties.length}');

    setState(() {
      _filteredProperties = _properties.where((property) {
        final matchesSearch = query.isEmpty ||
            property.title.toLowerCase().contains(query) ||
            property.location.toLowerCase().contains(query) ||
            property.description.toLowerCase().contains(query) ||
            (property.user?.name.toLowerCase().contains(query) ?? false);

        final matchesFilter = _selectedFilter == 'Tümü' ||
            (_selectedFilter == 'Satılık' && property.type == 'Satılık') ||
            (_selectedFilter == 'Kiralık' && property.type == 'Kiralık') ||
            (_selectedFilter == 'Öne Çıkan' && property.isFeatured);

        return matchesSearch && matchesFilter;
      }).toList();

      print('🔍 Filtreleme sonucu: ${_filteredProperties.length} ilan');
    });
  }

  Future<void> _deleteProperty(Property property) async {
    final confirmed = await _showDeleteDialog(property);
    if (!confirmed) return;

    try {
      await ApiService.deleteProperty(property.id!, property.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${property.title} başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );

      _loadProperties();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteDialog(Property property) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('İlanı Sil'),
            content: Text(
                '${property.title} ilanını silmek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlanlar'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProperties,
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
                    hintText: 'İlan ara...',
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
                      'Satılık',
                      'Kiralık',
                      'Öne Çıkan',
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
                            _filterProperties();
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

          // İlan Listesi
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
                              onPressed: _loadProperties,
                              child: Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _filteredProperties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'İlan bulunamadı',
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
                            itemCount: _filteredProperties.length,
                            itemBuilder: (context, index) {
                              final property = _filteredProperties[index];
                              return _buildPropertyCard(property);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          if (property.imageUrl.isNotEmpty)
            Image.network(
              'http://192.168.1.103:5238${property.imageUrl}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.home,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.home,
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve Fiyat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          property.type == 'Kiralık'
                              ? '₺${property.price.toStringAsFixed(0)}/ay'
                              : '₺${property.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4361ee),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: property.type == 'Kiralık'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: property.type == 'Kiralık'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            property.type,
                            style: TextStyle(
                              color: property.type == 'Kiralık'
                                  ? Colors.green
                                  : Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Özellikler
                Row(
                  children: [
                    _buildFeature(Icons.bed, '${property.rooms} oda'),
                    SizedBox(width: 16),
                    _buildFeature(Icons.bathtub, '${property.bathrooms} banyo'),
                    SizedBox(width: 16),
                    _buildFeature(
                        Icons.square_foot, '${property.area.toInt()} m²'),
                    if (property.parkingSpaces > 0) ...[
                      SizedBox(width: 16),
                      _buildFeature(Icons.local_parking,
                          '${property.parkingSpaces} park'),
                    ],
                  ],
                ),

                if (property.isFeatured) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Öne Çıkan',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Müteahhit Bilgisi
                if (property.user != null) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.user!.companyName ?? property.user!.name,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (property.user!.isVerified)
                        Icon(Icons.verified, size: 16, color: Colors.green),
                    ],
                  ),
                ],

                SizedBox(height: 12),

                // Tarih
                Text(
                  'Yayınlanma: ${_formatDate(property.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 12),

                // Aksiyon Butonları
                  Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4.0,
                  runSpacing: 0.0,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showPropertyDetails(property),
                      icon: Icon(Icons.info_outline, size: 16),
                      label: Text('Detay'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showEditDialog(property),
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                      label: Text('Düzenle', style: TextStyle(color: Colors.blue)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showWarningDialog(property),
                      icon: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      label: Text('Uyar', style: TextStyle(color: Colors.orange)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteProperty(property),
                      icon: Icon(Icons.delete, size: 16, color: Colors.red),
                      label: Text('Sil', style: TextStyle(color: Colors.red)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showPropertyDetails(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İlan Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Başlık', property.title),
              _buildDetailRow('Açıklama', property.description),
              _buildDetailRow(
                  'Fiyat',
                  property.type == 'Kiralık'
                      ? '₺${property.price.toStringAsFixed(0)}/ay'
                      : '₺${property.price.toStringAsFixed(0)}'),
              _buildDetailRow('Konum', property.location),
              _buildDetailRow('Tip', property.type),
              _buildDetailRow('Oda Sayısı', property.rooms.toString()),
              _buildDetailRow('Banyo Sayısı', property.bathrooms.toString()),
              _buildDetailRow('Alan', '${property.area.toInt()} m²'),
              _buildDetailRow('Park Yeri', property.parkingSpaces.toString()),
              _buildDetailRow(
                  'Öne Çıkan', property.isFeatured ? 'Evet' : 'Hayır'),
              if (property.user != null) ...[
                _buildDetailRow('Müteahhit', property.user!.name),
                if (property.user!.companyName != null)
                  _buildDetailRow('Şirket', property.user!.companyName!),
                _buildDetailRow(
                    'Onaylı', property.user!.isVerified ? 'Evet' : 'Hayır'),
              ],
              _buildDetailRow('Yayın Tarihi', _formatDate(property.createdAt)),
              _buildDetailRow('Durum', property.isActive ? 'Aktif' : 'Pasif'),
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

  Future<void> _showEditDialog(Property property) async {
    final titleController = TextEditingController(text: property.title);
    final descController = TextEditingController(text: property.description);
    final priceController = TextEditingController(text: property.price.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İlanı Düzenle (Admin)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Açıklama'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Güncelle'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final adminEmail = AuthService.currentUser?.email ?? 'admin@evatlas.com';
        await ApiService.adminUpdateProperty(
          property.id!,
          {
            'title': titleController.text,
            'description': descController.text,
            'price': priceController.text,
            'userId': property.userId, // Required by backend check logic flow
          },
          adminEmail,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('İlan güncellendi'), backgroundColor: Colors.green));
        _loadProperties();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showWarningDialog(Property property) async {
    final titleController = TextEditingController(text: 'İlanınız Hakkında Uyarı');
    final messageController = TextEditingController(text: '${property.title} başlıklı ilanınızda düzeltilmesi gerekenler var...');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kullanıcıya Uyarı Gönder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Konu'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Mesaj'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Gönder'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final adminEmail = AuthService.currentUser?.email ?? 'admin@evatlas.com';
        await ApiService.sendWarning(
          property.userId,
          titleController.text,
          messageController.text,
          adminEmail,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Uyarı gönderildi'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
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
