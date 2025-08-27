import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/lobby_controller.dart';

class LobbyView extends GetView<LobbyController> {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen Lottie background
          Positioned.fill(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Lottie.asset(
                'assets/gameBackground.json',
                fit: BoxFit.fill,
                repeat: true,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.purple.shade50,
                          Colors.purple.shade50,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Semi-transparent overlay for better content readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          // Main content over the background
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Obx(
                  () => Column(
                    children: [
                      const SizedBox(height: 20),

                      // Back button and header
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.purple,
                              ),
                              onPressed: () => controller.leaveLobby(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  ColorizeAnimatedText(
                                    '${controller.category} Lobby',
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    colors: [
                                      Colors.purple,
                                      Colors.blue,
                                      Colors.purple,
                                      Colors.teal,
                                    ],
                                    speed: const Duration(milliseconds: 400),
                                  ),
                                ],
                                isRepeatingAnimation: true,
                                repeatForever: true,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Waiting message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            AnimatedTextKit(
                              key: ValueKey(controller.waitingMessage),
                              animatedTexts: [
                                WavyAnimatedText(
                                  controller.waitingMessage,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                  speed: const Duration(milliseconds: 200),
                                ),
                              ],
                              isRepeatingAnimation: true,
                              repeatForever: true,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getStatusMessage(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            // Show game mode indicator
                            const SizedBox(height: 8),
                            _buildGameModeIndicator(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Player slots section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  controller.playersCountText,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Player slots based on actual players
                            ...List.generate(2, (index) {
                              if (index < controller.players.length) {
                                final player = controller.players[index];
                                final isCurrentUser =
                                    player.uid == controller.currentUser?.uid;
                                final isReady = controller.isPlayerReady(
                                  player.uid ?? '',
                                );
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == 0 ? 16 : 0,
                                  ),
                                  child: _buildPlayerSlot(
                                    playerNumber: index + 1,
                                    playerName: isCurrentUser
                                        ? 'You (${player.username})'
                                        : player.username,
                                    isConnected: true,
                                    isCurrentPlayer: isCurrentUser,
                                    avatarUrl: player.avatarUrl,
                                    isReady: isReady,
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == 0 ? 16 : 0,
                                  ),
                                  child: _buildPlayerSlot(
                                    playerNumber: index + 1,
                                    playerName: 'Waiting...',
                                    isConnected: false,
                                    isCurrentPlayer: false,
                                    avatarUrl: '',
                                    isReady: false,
                                  ),
                                );
                              }
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Ready button or Loading animation
                      if (controller.players.length == 2 &&
                          controller.gameStatus.value == 'waiting')
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Obx(() {
                            final isReady = controller.isCurrentUserReady;
                            return ElevatedButton.icon(
                              onPressed: isReady
                                  ? () => controller.cancelPlayerReady()
                                  : () => controller.setPlayerReady(),
                              icon: Icon(
                                isReady
                                    ? Icons.cancel_outlined
                                    : Icons.check_circle_outline,
                              ),
                              label: Text(
                                isReady ? 'Cancel Ready' : 'Ready to Start!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isReady
                                    ? Colors.orange
                                    : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 8,
                              ),
                            );
                          }),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              AnimatedTextKit(
                                key: ValueKey(controller.waitingMessage),
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    controller.waitingMessage,
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                    speed: const Duration(milliseconds: 100),
                                  ),
                                ],
                                isRepeatingAnimation: true,
                                repeatForever: true,
                                pause: const Duration(seconds: 2),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Cancel button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text('Leave Lobby?'),
                                content: Text(
                                  controller.players.length == 2
                                      ? 'Another player is waiting. Are you sure you want to leave?'
                                      : 'Are you sure you want to leave the lobby?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Stay'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.back(); // Close dialog
                                      controller.leaveLobby();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Leave'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Leave Lobby'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    if (controller.isSearching.value) {
      switch (controller.gameMode) {
        case 'friend_invitation':
          return 'Waiting for ${controller.friendName} to accept your invitation...';
        case 'friend_accepted':
          return 'Joining ${controller.friendName}\'s game...';
        default:
          return 'Looking for another player in ${controller.category}...';
      }
    } else {
      if (controller.players.length == 2) {
        return 'Both players joined! Get ready to start!';
      } else {
        return 'Waiting for the second player to join...';
      }
    }
  }

  Widget _buildGameModeIndicator() {
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;

    switch (controller.gameMode) {
      case 'friend_invitation':
        indicatorColor = Colors.purple;
        indicatorIcon = Icons.person_add;
        indicatorText = 'Friend Invitation';
        break;
      case 'friend_accepted':
        indicatorColor = Colors.green;
        indicatorIcon = Icons.group;
        indicatorText = 'Playing with Friend';
        break;
      default:
        indicatorColor = Colors.blue;
        indicatorIcon = Icons.shuffle;
        indicatorText = 'Random Match';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(indicatorIcon, size: 16, color: indicatorColor),
          const SizedBox(width: 6),
          Text(
            indicatorText,
            style: TextStyle(
              fontSize: 12,
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSlot({
    required int playerNumber,
    required String playerName,
    required bool isConnected,
    required bool isCurrentPlayer,
    required String avatarUrl,
    required bool isReady,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isConnected
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Player avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: isConnected && avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: isConnected ? Colors.green : Colors.grey,
                          size: 24,
                        );
                      },
                    )
                  : Icon(
                      isConnected ? Icons.person : Icons.person_outline,
                      color: isConnected ? Colors.green : Colors.grey,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Player $playerNumber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.green : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentPlayer) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (isConnected && isReady) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 10, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              'READY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  playerName,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Connection and ready status
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? (isReady ? Colors.green : Colors.orange)
                  : Colors.grey,
            ),
            child: isConnected && isReady
                ? const Icon(Icons.check, size: 8, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
