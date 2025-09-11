import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String? id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String user1Photo;
  final String user2Photo;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? lastSenderId;

  ConversationModel({
    this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.user1Photo,
    required this.user2Photo,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.lastSenderId,
  });

  factory ConversationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ConversationModel(
      id: documentId,
      user1Id: map['user1_id'] ?? '',
      user2Id: map['user2_id'] ?? '',
      user1Name: map['user1_name'] ?? '',
      user2Name: map['user2_name'] ?? '',
      user1Photo: map['user1_photo'] ?? '',
      user2Photo: map['user2_photo'] ?? '',
      lastMessage: map['last_message'],
      lastMessageAt: map['last_message_at'] != null
          ? (map['last_message_at'] as Timestamp).toDate()
          : null,
      unreadCount: map['unread_count'] ?? 0,
      lastSenderId: map['last_sender_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1_id': user1Id,
      'user2_id': user2Id,
      'user1_name': user1Name,
      'user2_name': user2Name,
      'user1_photo': user1Photo,
      'user2_photo': user2Photo,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'unread_count': unreadCount,
      'last_sender_id': lastSenderId,
    };
  }

  String getOtherPersonName(String currentUserId) {
    return currentUserId == user1Id ? user2Name : user1Name;
  }

  String getOtherPersonPhoto(String currentUserId) {
    return currentUserId == user1Id ? user2Photo : user1Photo;
  }

  String getOtherPersonId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  bool hasUnreadMessages(String currentUserId) {
    return unreadCount > 0 && lastSenderId != currentUserId;
  }
}

class MessageModel {
  final String? id;
  final String? conversationId;
  final String senderId;
  final String senderName;
  final String senderPhoto;
  final String? message;
  final DateTime messageDate;
  final String? imageUrl;
  final String? fileUrl;
  final String? voiceUrl;
  final String? messageType;
  final bool isRead;

  MessageModel({
    this.id,
    this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderPhoto,
    this.message,
    this.voiceUrl,
    required this.messageDate,
    this.imageUrl,
    this.fileUrl,
    this.messageType,
    this.isRead = false, // Default to unread
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Handle both DateTime and Timestamp for message_date
    DateTime parseMessageDate() {
      final messageDate = map['message_date'];
      if (messageDate is Timestamp) {
        return messageDate.toDate();
      } else if (messageDate is DateTime) {
        return messageDate;
      } else {
        return DateTime.now();
      }
    }

    return MessageModel(
      id: documentId,
      conversationId: map['conversation_id'],
      senderId: map['sender_id'] ?? '',
      senderName: map['sender_name'] ?? '',
      senderPhoto: map['sender_photo'] ?? '',
      message: map['message'],
      messageDate: parseMessageDate(),
      imageUrl: map['image_url'],
      fileUrl: map['file_url'],
      voiceUrl: map['voice_url'],
      messageType: map['message_type'],
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_photo': senderPhoto,
      'message': message ?? '', // This will be encrypted when stored
      'message_date': Timestamp.fromDate(messageDate),
      'image_url': imageUrl,
      'file_url': fileUrl,
      'voice_url': voiceUrl,
      'message_type': messageType ?? 'text',
      'is_read': isRead,
    };
  }

  // Helper methods (remove role-based helpers if not needed)
}
