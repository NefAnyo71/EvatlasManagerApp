class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePhotoUrl;
  final bool isContractor;
  final bool isVerified;
  final bool isBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final String? bannedBy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? companyName;
  final String? businessNumber;
  final String? taxNumber;
  final String? lastIpAddress;
  final DateTime? lastLoginAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePhotoUrl,
    this.isContractor = false,
    this.isVerified = false,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.bannedBy,
    this.isActive = true,
    required this.createdAt,
    this.deletedAt,
    this.companyName,
    this.businessNumber,
    this.taxNumber,
    this.lastIpAddress,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePhotoUrl: json['profilePhotoUrl'],
      isContractor: json['isContractor'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isBanned: json['isBanned'] ?? false,
      banReason: json['banReason'],
      bannedAt: json['bannedAt'] != null ? DateTime.parse(json['bannedAt']) : null,
      bannedBy: json['bannedBy'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      companyName: json['companyName'],
      businessNumber: json['businessNumber'],
      taxNumber: json['taxNumber'],
      lastIpAddress: json['lastIpAddress'],
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'isContractor': isContractor,
      'isVerified': isVerified,
      'isBanned': isBanned,
      'banReason': banReason,
      'bannedAt': bannedAt?.toIso8601String(),
      'bannedBy': bannedBy,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'companyName': companyName,
      'businessNumber': businessNumber,
      'taxNumber': taxNumber,
      'lastIpAddress': lastIpAddress,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}