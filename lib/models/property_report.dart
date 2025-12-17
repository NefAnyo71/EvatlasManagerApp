import 'user.dart';
import 'property.dart';

class PropertyReport {
  final int? id;
  final int propertyId;
  final Property? property;
  final int reportedByUserId;
  final User? reportedByUser;
  final String reportReason;
  final String? reportDetails;
  final DateTime reportedAt;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? adminNotes;

  PropertyReport({
    this.id,
    required this.propertyId,
    this.property,
    required this.reportedByUserId,
    this.reportedByUser,
    required this.reportReason,
    this.reportDetails,
    required this.reportedAt,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.adminNotes,
  });

  factory PropertyReport.fromJson(Map<String, dynamic> json) {
    return PropertyReport(
      id: json['id'],
      propertyId: json['propertyId'] ?? 0,
      property: json['property'] != null ? Property.fromJson(json['property']) : null,
      reportedByUserId: json['reportedByUserId'] ?? 0,
      reportedByUser: json['reportedBy'] != null ? User.fromJson(json['reportedBy']) : null,
      reportReason: json['reportReason'] ?? '',
      reportDetails: json['reportDetails'],
      reportedAt: json['reportedAt'] != null 
          ? DateTime.parse(json['reportedAt']) 
          : DateTime.now(),
      isResolved: json['isResolved'] ?? false,
      resolvedBy: json['resolvedBy'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      adminNotes: json['adminNotes'],
    );
  }
}