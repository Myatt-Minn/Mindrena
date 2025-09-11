import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as GetX;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/messageModel.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetX.GetxController {
  var messages = <MessageModel>[].obs;
  var isLoading = true.obs; // Start with loading true
  var isUploading = false.obs;
  var canSend = false.obs;
  final userId = 0.obs;
  var name = ''.obs;
  var email = ''.obs;
  var avatar = ''.obs;
  var receiverFcmToken = ''.obs;
  var conversation = GetX.Rxn<ConversationModel>();
  final TextEditingController messageController = TextEditingController();
  final picker = ImagePicker();
  String uploadedFileUrl = "";
  final ScrollController scrollController = ScrollController();
  var unreadCount = 0.obs;
  final user = GetX.Rxn<UserModel>();
  var storage = GetStorage();
  RxString selectedMessageId = ''.obs;

  @override
  void onInit() async {
    super.onInit();

    print('ChatController onInit started');

    // Get conversation from arguments
    final conversationArg = GetX.Get.arguments;
    print('Conversation argument type: ${conversationArg.runtimeType}');
    print('Conversation argument: $conversationArg');

    if (conversationArg is ConversationModel) {
      conversation.value = conversationArg;
      print('Conversation loaded: ${conversation.value?.id}');
      print(
        'Conversation users: ${conversation.value?.user1Id} and ${conversation.value?.user2Id}',
      );
    } else {
      print('Invalid conversation argument: $conversationArg');
      GetX.Get.snackbar(
        'Error',
        'Invalid conversation data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      GetX.Get.back();
      return;
    }

    // Get current user data
    final userData = storage.read('user');
    print('User data from storage: $userData');

    if (userData != null) {
      user.value = UserModel.fromMap(userData);
      print('User loaded from storage: ${user.value?.uid}');
      print(
        'User details: username=${user.value?.username}, email=${user.value?.email}, avatarUrl=${user.value?.avatarUrl}',
      );
    } else {
      print('No user data in storage, trying Firebase Auth');
      // Fallback: get from Firebase Auth if not in storage
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentFirebaseUser.uid)
              .get();

          if (userDoc.exists) {
            user.value = UserModel.fromMap(userDoc.data()!);
            // Store in storage for future use
            await storage.write('user', user.value!.toMap());
            print('User loaded from Firebase: ${user.value?.uid}');
            print(
              'User details from Firebase: username=${user.value?.username}, email=${user.value?.email}, avatarUrl=${user.value?.avatarUrl}',
            );
          } else {
            throw Exception('User document not found');
          }
        } catch (e) {
          print('Error loading user from Firebase: $e');
          GetX.Get.snackbar(
            'Error',
            'Failed to load user data',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          GetX.Get.back();
          return;
        }
      } else {
        print('No user data found and no Firebase user');
        GetX.Get.snackbar(
          'Error',
          'User session expired',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        GetX.Get.back();
        return;
      }
    }

    print('Starting to listen to messages');
    listenToMessages();

    // Listen to text field changes
    messageController.addListener(() {
      canSend.value =
          messageController.text.trim().isNotEmpty && !isUploading.value;
    });

    scrollToBottom();

    // Mark messages as read when entering chat
    await markMessagesAsRead();

    // Set loading to false after initialization is complete
    isLoading.value = false;

    print('ChatController onInit completed');
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void listenToMessages() {
    if (conversation.value == null) {
      print('No conversation available for listening to messages');
      return;
    }

    print(
      'Starting to listen to messages for conversation: ${conversation.value!.id}',
    );

    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversation.value!.id)
        .collection('messages')
        .orderBy('message_date', descending: false)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            print('Received ${snapshot.docs.length} messages from Firestore');

            try {
              messages.value = snapshot.docs
                  .map((doc) {
                    try {
                      var messageData = doc.data() as Map<String, dynamic>;
                      print(
                        'Processing message: ${doc.id} - ${messageData['message']}',
                      );
                      print(
                        'Message date type: ${messageData['message_date'].runtimeType}',
                      );
                      return MessageModel.fromMap(messageData, doc.id);
                    } catch (e) {
                      print(
                        'Error processing individual message ${doc.id}: $e',
                      );
                      // Skip this message and continue with others
                      return null;
                    }
                  })
                  .where((message) => message != null)
                  .cast<MessageModel>()
                  .toList();

              print('Successfully processed ${messages.length} messages');

              // Calculate unread count using the correct user ID
              String currentUserId = user.value?.uid ?? '';
              int unreadMessages = messages
                  .where(
                    (message) =>
                        message.senderId != currentUserId && !message.isRead,
                  )
                  .length;
              unreadCount.value = unreadMessages;

              scrollToBottom();

              // Only mark messages as read if there are actually unread messages from OTHER users
              // Don't mark messages as read immediately after sending your own message
              if (unreadMessages > 0) {
                // Add a small delay to prevent race condition
                Future.delayed(Duration(milliseconds: 500), () {
                  markMessagesAsRead();
                });
              }
            } catch (e) {
              print('Error processing messages: $e');
            }
          },
          onError: (e) {
            print('Error listening to messages: $e');
          },
        );
  }

  Future<void> markMessagesAsRead() async {
    if (conversation.value == null) return;

    try {
      String currentUserId = user.value?.uid ?? '';

      // Get unread messages from OTHER users only (not from yourself)
      final unreadMessages = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.value!.id)
          .collection('messages')
          .where('sender_id', isNotEqualTo: currentUserId)
          .where('is_read', isEqualTo: false)
          .get();

      // Only proceed if there are actually unread messages from other users
      if (unreadMessages.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Mark only OTHER users' messages as read
        for (var doc in unreadMessages.docs) {
          var messageData = doc.data();
          String messageSenderId = messageData['sender_id'] ?? '';

          // Double check - only mark as read if it's NOT from current user
          if (messageSenderId != currentUserId) {
            batch.update(doc.reference, {'is_read': true});
          }
        }

        await batch.commit();

        // Update conversation unread count only if we actually marked messages as read
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversation.value!.id)
            .update({'unread_count': 0});

        print('Marked ${unreadMessages.docs.length} messages as read');
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> sendMessage({
    String? imageUrl,
    String? fileUrl,
    bool skipUploadingCheck = false,
  }) async {
    // Only check isUploading if this is not an internal call
    if (!skipUploadingCheck && isUploading.value) {
      return; // Prevent multiple sends
    }

    String messageText = messageController.text.trim();

    // Don't send if no content
    if (messageText.isEmpty && imageUrl == null && fileUrl == null) {
      return;
    }

    if (conversation.value == null) {
      print('Cannot send message: no conversation');
      return;
    }

    if (user.value == null || user.value?.uid == null) {
      print('Cannot send message: user data not loaded');

      // Try to reload user data before failing
      final userData = storage.read('user');
      if (userData != null) {
        user.value = UserModel.fromMap(userData);
        print('Reloaded user data from storage for message sending');
      } else {
        // Final fallback: get from Firebase Auth
        final currentFirebaseUser = FirebaseAuth.instance.currentUser;
        if (currentFirebaseUser != null) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(currentFirebaseUser.uid)
                .get();
            if (userDoc.exists) {
              user.value = UserModel.fromMap(userDoc.data()!);
              await storage.write('user', user.value!.toMap());
              print('Reloaded user data from Firebase for message sending');
            }
          } catch (e) {
            print('Failed to reload user data: $e');
          }
        }
      }

      // If still no user data, show error
      if (user.value == null || user.value?.uid == null) {
        GetX.Get.snackbar(
          "Error",
          "User data not loaded. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Only set isUploading if this is not an internal call
    if (!skipUploadingCheck) {
      isUploading.value = true;
      canSend.value = false;
    }

    try {
      String messageId = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.value!.id)
          .collection('messages')
          .doc()
          .id;

      String displayMessage = '';

      if (imageUrl != null) {
        displayMessage = '📷 Image';
      } else if (fileUrl != null) {
        displayMessage = '📎 File';
      } else {
        displayMessage = messageText;
      }

      MessageModel message = MessageModel(
        id: messageId,
        conversationId: conversation.value!.id,
        senderId: user.value?.uid ?? '',
        senderName: user.value?.username ?? 'Unknown User',
        senderPhoto: user.value?.avatarUrl ?? '',
        message: messageText,
        messageDate: DateTime.now(),
        imageUrl: imageUrl,
        fileUrl: fileUrl,
        messageType: imageUrl != null
            ? 'image'
            : (fileUrl != null ? 'file' : 'text'),
        isRead: false,
      );

      // Create a map for Firestore with debugging
      Map<String, dynamic> messageMap = message.toMap();

      // Debug the message data before sending
      print('Message data being sent:');
      print('sender_id: ${messageMap['sender_id']}');
      print('sender_name: ${messageMap['sender_name']}');
      print('sender_photo: ${messageMap['sender_photo']}');
      print('message: ${messageMap['message']}');
      print(
        'User data: uid=${user.value?.uid}, username=${user.value?.username}, avatarUrl=${user.value?.avatarUrl}',
      );

      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.value!.id)
          .collection('messages')
          .doc(messageId)
          .set(messageMap);

      // Update conversation
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.value!.id)
          .update({
            'last_message': displayMessage,
            'last_message_at': Timestamp.fromDate(DateTime.now()),
            'last_sender_id': user.value?.uid ?? '',
            'unread_count': FieldValue.increment(1),
          });

      scrollToBottom();
      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      GetX.Get.snackbar(
        "Error",
        "Failed to send message. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Only reset state if this is not an internal call
      if (!skipUploadingCheck) {
        isUploading.value = false;
        canSend.value = messageController.text.trim().isNotEmpty;
      }
    }
  }

  Future<void> sendFile() async {
    if (isUploading.value) return;

    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      GetX.Get.snackbar(
        "Permission Denied",
        "Storage permission is required to access files.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;
    canSend.value = false;

    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        return;
      }

      PlatformFile pickedFile = result.files.first;
      File file = File(pickedFile.path!);
      String fileName =
          'files/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(file);
      String fileUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(fileUrl: fileUrl, skipUploadingCheck: true);
    } catch (e) {
      print('Error uploading file: $e');
      GetX.Get.snackbar(
        "Upload Failed",
        "Failed to upload file. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      canSend.value = messageController.text.trim().isNotEmpty;
    }
  }

  Future<void> sendImage(ImageSource source) async {
    if (isUploading.value) return;

    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      GetX.Get.snackbar(
        "Permission Denied",
        "Storage permission is required to access images.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;
    canSend.value = false;

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) {
        return;
      }

      File imageFile = File(pickedFile.path);
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(imageFile);
      String imageUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(imageUrl: imageUrl, skipUploadingCheck: true);
    } catch (e) {
      print('Error uploading image: $e');
      GetX.Get.snackbar(
        "Upload Failed",
        "Failed to upload image. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      canSend.value = messageController.text.trim().isNotEmpty;
    }
  }

  void showImageSourceDialog() {
    if (isUploading.value) return;

    GetX.Get.defaultDialog(
      title: "Choose Image Source",
      content: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.camera, color: Colors.blue),
            title: const Text("Take a Photo"),
            onTap: () {
              GetX.Get.back();
              sendImage(ImageSource.camera);
            },
          ),
          SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.green),
            title: const Text("Choose from Gallery"),
            onTap: () {
              GetX.Get.back();
              sendImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+): use granular media permissions
        final photos = await Permission.photos.request();

        // For downloading images, we mainly need photos permission
        if (photos.isGranted) {
          return true;
        }

        // If photos permission is denied, try storage permission as fallback
        final storage = await Permission.storage.request();

        return storage.isGranted;
      } else {
        // API 32 and below: use storage permission
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return true; // iOS doesn't need this
  }

  Future<void> downloadImage(String url, BuildContext context) async {
    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Storage permission is required to download files."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      isUploading.value = true;

      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text("Downloading image..."),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // For now, just show success since we removed Dio dependency
      // In a real implementation, you'd need to add dio dependency back
      // and handle the download properly

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Image download feature temporarily disabled"),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("Error downloading image: $e");

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text("Failed to download image"),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isUploading.value = false;
    }
  }
}
