import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/models/call_model.dart';
import 'package:talkliner/app/themes/talkliner_dimens.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/calling/widgets/livekit_signal_widget.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  double xPosition = 20;
  double yPosition = 50;

  @override
  void initState() {
    super.initState();
    // Enable wakelock to keep the screen awake during the call
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CallController>().isCallScreenActive.value = true;
      Get.find<CallController>().updateAutoPip(true);
    });
  }

  @override
  void dispose() {
    // Disable wakelock when the call screen is disposed
    WakelockPlus.disable();
    // Defer state update to next frame to avoid scheduling rebuilds during unmount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().isCallScreenActive.value = false;
      }
    });
    Get.find<CallController>().updateAutoPip(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
      body: Obx(() {
        final call = callController.activeCall.value;
        final room = callController.room;

        if (call == null) {
          return Center(child: Text("No Active Call"));
        }

        final user = call.participants.first;

        // Helper to find video track
        VideoTrack? getRemoteVideoTrack() {
          if (room != null && room.remoteParticipants.isNotEmpty) {
            final participant = room.remoteParticipants.values.first;
            final track = participant.videoTrackPublications.firstOrNull?.track;
            return track;
          }
          return null;
        }

        VideoTrack? getLocalVideoTrack() {
          if (room != null && room.localParticipant != null) {
            final track =
                room
                    .localParticipant!
                    .videoTrackPublications
                    .firstOrNull
                    ?.track;
            return track;
          }
          return null;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isPipMode =
                constraints.maxHeight < 300; // Heuristic for PiP window

            return Stack(
              children: [
                // Remote Video or Avatar
                Positioned.fill(
                  child:
                      getRemoteVideoTrack() != null
                          ? VideoTrackRenderer(
                            getRemoteVideoTrack()!,
                            fit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isPipMode) ...[
                                Spacer(),
                                UserAvatar(
                                  user: user,
                                  size: TalklinerDimens.avatarSizeExtraLarge,
                                  indicator: false,
                                ),
                                SizedBox(height: TalklinerDimens.spacingLarge),
                                Text(
                                  user.displayName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: TalklinerDimens.spacingSmall),
                              ],
                              (call.status != CallStatus.accepted)
                                  ? Text(
                                    call.status.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  )
                                  : SizedBox(),
                              if (callController.durationString.isNotEmpty &&
                                  !isPipMode)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    callController.durationString.value,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ),
                              if (!isPipMode) Spacer(),
                              if (!isPipMode)
                                SizedBox(
                                  height: TalklinerDimens.spacingExtraLarge,
                                ), // Space for controls
                            ],
                          ),
                ),

                // Local Video (PIP) - Draggable
                if (getLocalVideoTrack() != null &&
                    callController.isVideoEnabled.value)
                  Positioned(
                    right: xPosition,
                    bottom: yPosition,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          yPosition -= details.delta.dy;
                          xPosition -=
                              details.delta.dx; // Right-aligned, so subtract dx
                        });
                      },
                      child: Container(
                        width: TalklinerDimens.pipWidth,
                        height: TalklinerDimens.pipHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            TalklinerDimens.pipBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            TalklinerDimens.pipBorderRadius,
                          ),
                          child: VideoTrackRenderer(
                            getLocalVideoTrack()!,
                            fit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Controls
                if (!isPipMode)
                  Positioned(
                    bottom: TalklinerDimens.callControlsBottomMargin,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Speaker
                        FloatingActionButton(
                          heroTag: 'speaker_btn',
                          backgroundColor:
                              callController.isSpeakerOn.value
                                  ? TalklinerThemeColors.primary500
                                  : isDarkMode
                                  ? TalklinerThemeColors.gray900
                                  : Colors.white,
                          shape: CircleBorder(),
                          elevation: 0,
                          onPressed: callController.toggleSpeaker,
                          child: Icon(
                            LucideIcons.volume2,
                            size: TalklinerDimens.iconSizeLarge,
                            color:
                                callController.isSpeakerOn.value
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                          ),
                        ),

                        // Video Toggle
                        FloatingActionButton(
                          heroTag: 'video_btn',
                          backgroundColor:
                              !callController.isVideoEnabled.value
                                  ? TalklinerThemeColors.red500
                                  : isDarkMode
                                  ? TalklinerThemeColors.gray900
                                  : Colors.white,
                          shape: CircleBorder(),
                          elevation: 0,
                          onPressed: callController.toggleVideo,
                          child: Icon(
                            callController.isVideoEnabled.value
                                ? LucideIcons.video
                                : LucideIcons.videoOff,
                            size: TalklinerDimens.iconSizeLarge,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        // Mute
                        FloatingActionButton(
                          heroTag: 'mute_btn',
                          backgroundColor:
                              callController.isMuted.value
                                  ? TalklinerThemeColors.red500
                                  : isDarkMode
                                  ? TalklinerThemeColors.gray900
                                  : Colors.white,
                          shape: CircleBorder(),
                          elevation: 0,
                          onPressed: callController.toggleMute,
                          child: Icon(
                            callController.isMuted.value
                                ? LucideIcons.micOff
                                : LucideIcons.mic,
                            size: TalklinerDimens.iconSizeLarge,
                            color:
                                callController.isMuted.value
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                          ),
                        ),

                        // End Call
                        FloatingActionButton(
                          heroTag: 'end_btn',
                          backgroundColor: TalklinerThemeColors.red500,
                          shape: CircleBorder(),
                          elevation: 0,
                          onPressed: () => callController.endCall(call),
                          child: Icon(LucideIcons.x, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                if (callController.isVideoEnabled.value && !isPipMode)
                  Positioned(
                    right: TalklinerDimens.spacingMedium,
                    bottom: TalklinerDimens.callFlipCameraBottomMargin,
                    child: // Flip Camera
                        FloatingActionButton(
                      heroTag: 'flip_btn',
                      backgroundColor:
                          isDarkMode
                              ? TalklinerThemeColors.gray900
                              : Colors.white,
                      shape: CircleBorder(),
                      elevation: 0,
                      onPressed: callController.flipCamera,
                      child: Icon(
                        Icons.cameraswitch_outlined,
                        size: TalklinerDimens.iconSizeLarge,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                if (!isPipMode)
                  Positioned(
                    top: TalklinerDimens.callTopBarTopMargin,
                    right: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: TalklinerDimens.spacingSmall,
                      ),
                      height: TalklinerDimens.callTopBarHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.chevronLeft,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Back",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.displayName,
                                style: TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                spacing: TalklinerDimens.spacingMedium,
                                children: [
                                  LiveKitSignalWidget(),
                                  Obx(
                                    () => Text(
                                      callController.durationString.value,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }
}
