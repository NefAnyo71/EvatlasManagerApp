import 'user.dart';

class Property {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String type;
  final int rooms;
  final int bathrooms;
  final double area;
  final int parkingSpaces;
  final String imageUrl;
  final bool isFeatured;
  final int userId;
  final User? user;
  final DateTime createdAt;
  final bool isActive;
  final List<String> images;

  Property({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    required this.rooms,
    required this.bathrooms,
    required this.area,
    required this.parkingSpaces,
    required this.imageUrl,
    this.isFeatured = false,
    required this.userId,
    this.user,
    required this.createdAt,
    this.isActive = true,
    this.images = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      rooms: json['rooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      parkingSpaces: json['parkingSpaces'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      userId: json['userId'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'type': type,
      'rooms': rooms,
      'bathrooms': bathrooms,
      'area': area,
      'parkingSpaces': parkingSpaces,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'userId': userId,
      'user': user?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'images': images,
    };
  }
}