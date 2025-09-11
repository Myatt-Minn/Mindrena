import 'dart:async'; // Add this import

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindrena/app/data/consts_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => controller.isLoading.value
                ? CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          controller.conversation.value?.getOtherPersonPhoto(
                                controller.user.value?.uid ?? '',
                              ) ??
                              'https://static.vecteezy.com/system/resources/previews/019/153/517/non_2x/avatar-of-a-teacher-character-free-vector.jpg',
                        ),
                        radius: 16,
                      ),
                      SizedBox(width: 16),
                      Text(
                        controller.conversation.value!.getOtherPersonName(
                          controller.user.value?.uid ?? '',
                        ),
                      ),
                    ],
                  ),
          ),
          centerTitle: true,
          backgroundColor: ConstsConfig.primarycolor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            Obx(
              () => controller.isUploading.value
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Processing...",
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
            ),

            // Messages List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: controller.messages.length,

                  // In your ListView.builder itemBuilder, replace the message display section with this:
                  itemBuilder: (context, index) {
                    var message = controller.messages[index];
                    bool isSentByUser =
                        message.senderId == controller.user.value?.uid;

                    // Check if this is the first message from this sender in a sequence
                    bool showAvatar = true;
                    if (index < controller.messages.length - 1) {
                      var nextMessage = controller.messages[index + 1];
                      if (nextMessage.senderId == message.senderId) {
                        showAvatar = false;
                      }
                    }

                    // Also check if messages are within 2 minutes of each other
                    if (index < controller.messages.length - 1 && !showAvatar) {
                      var nextMessage = controller.messages[index + 1];
                      var timeDifference = nextMessage.messageDate
                          .difference(message.messageDate)
                          .inMinutes;
                      if (timeDifference > 2) {
                        showAvatar = true;
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: showAvatar
                            ? 4
                            : 1, // Reduce spacing for grouped messages
                      ),
                      child: Align(
                        alignment: isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isSentByUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // All messages without container background
                            Row(
                              mainAxisAlignment: isSentByUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Avatar for received messages ONLY - only show for last message in sequence
                                if (!isSentByUser) ...[
                                  showAvatar
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            message.senderPhoto.isEmpty
                                                ? 'https://static.vecteezy.com/system/resources/previews/019/153/517/non_2x/avatar-of-a-teacher-character-free-vector.jpg'
                                                : message.senderPhoto,
                                          ),
                                          radius: 16,
                                        )
                                      : SizedBox(
                                          width: 32,
                                        ), // Empty space to maintain alignment
                                  SizedBox(width: 8),
                                ],

                                // Message content container
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Toggle timestamp visibility for this message
                                      if (controller.selectedMessageId.value ==
                                          message.id) {
                                        controller.selectedMessageId.value = '';
                                      } else {
                                        controller.selectedMessageId.value =
                                            message.id ?? '';
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSentByUser
                                            ? ConstsConfig.primarycolor
                                            : ConstsConfig.secondarycolor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomLeft: isSentByUser
                                              ? Radius.circular(12)
                                              : (showAvatar
                                                    ? Radius.circular(4)
                                                    : Radius.circular(12)),
                                          bottomRight: isSentByUser
                                              ? Radius.circular(
                                                  12,
                                                ) // Always rounded for user messages since no avatar
                                              : Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image Display
                                          if (message.imageUrl != null &&
                                              message.imageUrl!.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                Get.toNamed(
                                                  '/full-network-image',
                                                  arguments: message.imageUrl,
                                                );
                                              },
                                              onLongPress: () {
                                                _showImageOptions(
                                                  context,
                                                  message.imageUrl!,
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: FancyShimmerImage(
                                                  imageUrl: message.imageUrl!,
                                                  width: 200,
                                                  height: 200,
                                                  boxFit: BoxFit.cover,
                                                  errorWidget: Container(
                                                    width: 200,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color:
                                                          Colors.grey.shade600,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          // File Display
                                          if (message.fileUrl != null &&
                                              message.fileUrl!.isNotEmpty)
                                            Container(
                                              width: double.infinity,
                                              margin: EdgeInsets.only(
                                                bottom:
                                                    (message.message != null &&
                                                        message
                                                            .message!
                                                            .isNotEmpty)
                                                    ? 8
                                                    : 0,
                                              ),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.attach_file,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _getFileNameFromUrl(
                                                            message.fileUrl!,
                                                          ),
                                                          style:
                                                              GoogleFonts.manrope(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                              ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Tap to download',
                                                          style:
                                                              GoogleFonts.manrope(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.7,
                                                                    ),
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _downloadFile(
                                                      message.fileUrl!,
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.download,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          // Text Message
                                          if (message.message != null &&
                                              message.message!.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top:
                                                    (message.imageUrl != null ||
                                                        message.fileUrl != null)
                                                    ? 8.0
                                                    : 0,
                                              ),
                                              child: Text(
                                                message.message!,
                                                style: GoogleFonts.manrope(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // NO AVATAR FOR SENT MESSAGES - completely removed this section
                              ],
                            ),

                            // Timestamp - Only show when message is selected
                            Obx(() {
                              if (controller.selectedMessageId.value ==
                                  message.id) {
                                return Column(
                                  children: [
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSentByUser
                                            ? 0
                                            : 32, // No padding for user messages since no avatar
                                      ),
                                      child: Text(
                                        _formatDate(message.messageDate),
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Message Input Field
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Obx(
                () => Row(
                  children: [
                    // File Upload Button (now includes image and file options)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: controller.isUploading.value
                              ? null
                              : () => _showAttachmentOptions(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: controller.isUploading.value
                                    ? Colors.grey.shade300
                                    : ConstsConfig.primarycolor.withOpacity(
                                        0.1,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.attach_file,
                                color: controller.isUploading.value
                                    ? Colors.grey.shade500
                                    : ConstsConfig.primarycolor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Text Input Field
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: controller.messageController,
                          maxLines: null,
                          minLines: 1,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Aa',
                            hintStyle: GoogleFonts.manrope(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            // Optional: Add typing indicator logic here
                          },
                        ),
                      ),
                    ),

                    // Send Button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (controller.messageController.text
                                    .trim()
                                    .isNotEmpty &&
                                !controller.isUploading.value) {
                              controller.sendMessage();
                            } else if (controller.messageController.text
                                .trim()
                                .isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please type a message',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange.shade100,
                                colorText: Colors.orange.shade800,
                                duration: Duration(seconds: 2),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: !controller.isUploading.value
                                    ? LinearGradient(
                                        colors: [
                                          ConstsConfig.primarycolor,
                                          ConstsConfig.primarycolor.withOpacity(
                                            0.8,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow:
                                    controller.messageController.text
                                            .trim()
                                            .isNotEmpty &&
                                        !controller.isUploading.value
                                    ? [
                                        BoxShadow(
                                          color: ConstsConfig.primarycolor
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: controller.isUploading.value
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final isToday =
        dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    return isToday
        ? "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}"
        : "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _getFileNameFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last;

      // Remove Firebase Storage timestamp prefix if present
      if (path.contains('_')) {
        int underscoreIndex = path.indexOf('_');
        if (underscoreIndex != -1 && underscoreIndex < path.length - 1) {
          String withoutTimestamp = path.substring(underscoreIndex + 1);
          return withoutTimestamp.isNotEmpty ? withoutTimestamp : path;
        }
      }

      return path.isNotEmpty ? path : 'File';
    } catch (e) {
      return 'File';
    }
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      final Uri url = Uri.parse(fileUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add this method at the end of the ChatView class, before the closing brace:
  // Replace the _showAttachmentOptions method with this:

  void _showAttachmentOptions(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        20, // Left position
        MediaQuery.of(context).size.height -
            200, // Top position (above the input field)
        MediaQuery.of(context).size.width - 20, // Right position
        MediaQuery.of(context).size.height - 100, // Bottom position
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        // Camera/Gallery Option
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.purple.shade700,
                size: 20,
              ),
            ),
            title: Text(
              "Camera/Gallery",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Take photo or select from gallery",
              style: GoogleFonts.manrope(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              controller.showImageSourceDialog();
            },
          ),
        ),

        // Divider
        PopupMenuItem(
          padding: EdgeInsets.zero,
          height: 1,
          child: Divider(height: 1),
        ),

        // File Upload Option
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.file_upload,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
            title: Text(
              "Upload File",
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Documents, PDFs, etc.",
              style: GoogleFonts.manrope(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              controller.sendFile();
            },
          ),
        ),
      ],
    );
  }

  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.fullscreen, color: Colors.blue),
                title: Text('View Full Size'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/full-network-image', arguments: imageUrl);
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Colors.green),
                title: Text('Download Image'),
                onTap: () {
                  Navigator.pop(context);
                  controller.downloadImage(imageUrl, context);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
