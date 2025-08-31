import 'package:get/get.dart';

class FeedBackModel {
  final String feedbackId;
  final String userId;
  final String username;
  final String userProfileUrl;
  final String email;
  final String phone;
  final String feedbackType;
  final int rating;
  final String title;
  final String message;
  final String status;
  final String adminResponse;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  FeedBackModel({
    required this.feedbackId,
    required this.userId,
    required this.username,
    this.userProfileUrl = '',
    required this.email,
    this.phone = '',
    required this.feedbackType,
    this.rating = 0,
    required this.title,
    required this.message,
    this.status = 'pending',
    this.adminResponse = '',
    this.createdAt,
    this.respondedAt,
  });

  // Factory constructor to create from JSON
  factory FeedBackModel.fromJson(Map<String, dynamic> json) {
    return FeedBackModel(
      feedbackId: json['feedbackid']?.toString() ?? '',
      userId: json['userid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userProfileUrl: json['userprofileurl']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      feedbackType: json['feedbacktype']?.toString() ?? '',
      rating: _parseToInt(json['rating']),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      adminResponse: json['adminresponse']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdat']),
      respondedAt: _parseDateTime(json['respondedat']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'feedbackid': feedbackId,
      'userid': userId,
      'username': username,
      'userprofileurl': userProfileUrl,
      'email': email,
      'phone': phone,
      'feedbacktype': feedbackType,
      'rating': rating,
      'title': title,
      'message': message,
      'status': status,
      'adminresponse': adminResponse,
      'createdat': createdAt?.toIso8601String(),
      'respondedat': respondedAt?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  FeedBackModel copyWith({
    String? feedbackId,
    String? userId,
    String? username,
    String? userProfileUrl,
    String? email,
    String? phone,
    String? feedbackType,
    int? rating,
    String? title,
    String? message,
    String? status,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FeedBackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      feedbackType: feedbackType ?? this.feedbackType,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      message: message ?? this.message,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  // Helper method to parse integer safely
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to parse DateTime safely
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String get feedbackTypeDisplay {
    switch (feedbackType.toLowerCase()) {
      case 'product':
        return 'feedback_type_product'.tr;
      case 'service':
        return 'feedback_type_service'.tr;
      case 'delivery':
        return 'feedback_type_delivery'.tr;
      case 'app':
        return 'feedback_type_app'.tr;
      case 'general':
        return 'feedback_type_general'.tr;
      default:
        return 'feedback_type_default'.tr;
    }
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'feedback_status_pending'.tr;
      case 'reviewed':
        return 'feedback_status_reviewed'.tr;
      case 'resolved':
        return 'feedback_status_resolved'.tr;
      case 'rejected':
        return 'feedback_status_rejected'.tr;
      default:
        return 'feedback_status_unknown'.tr;
    }
  }
}
