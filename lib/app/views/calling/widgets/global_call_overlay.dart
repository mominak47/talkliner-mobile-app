import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' as livekit;
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/models/call_model.dart';
import 'package:talkliner/app/themes/talkliner_dimens.dart';
import 'package:talkliner/app/views/calling/call_screen.dart';

class GlobalCallOverlay extends StatefulWidget {
  const GlobalCallOverlay({super.key});

  @override
  State<GlobalCallOverlay> createState() => _GlobalCallOverlayState();
}

class _GlobalCallOverlayState extends State<GlobalCallOverlay> {
  // Initial safe position (bottom right)
  double xPosition = 20;
  double yPosition = 100;

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();

    return Obx(() {
      final call = callController.activeCall.value;
      final room = callController.room;
      // Show PIP only if:
      // 1. There is an active call
      // 2. Call status is accepted
      // 3. User is NOT on the main CallScreen
      // 4. Room is connected
      bool shouldShow =
          call != null &&
          call.status == CallStatus.accepted &&
          callController.isCallScreenActive.value == false &&
          room != null &&
          room.connectionState == livekit.ConnectionState.connected;

      if (!shouldShow) return SizedBox.shrink();

      livekit.VideoTrack? getRemoteVideoTrack() {
        if (room != null && room.remoteParticipants.isNotEmpty) {
          final participant = room.remoteParticipants.values.first;
          final track = participant.videoTrackPublications.firstOrNull?.track;
          return track;
        }
        return null;
      }

      // If we are audio only, maybe we still want a small indicator?
      // For now requirement is "video call I want to see a small pip video".
      // Let's show it if video track exists or just avatar if audio only?
      // User said "pip video of the remote stream", implying video.
      final remoteTrack = getRemoteVideoTrack();

      // If no video track, we can choose to hide or show an avatar.
      // Let's hide if no video track to keep it clean as per request "pip video".
      if (remoteTrack == null) return SizedBox.shrink();

      return Positioned(
        right: xPosition,
        bottom: yPosition,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              yPosition -= details.delta.dy;
              xPosition -= details.delta.dx;
            });
          },
          onTap: () {
            // Navigate back to call screen
            Get.to(() => CallScreen());
          },
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(
              TalklinerDimens.pipBorderRadius,
            ),
            color: Colors.black,
            child: Container(
              width: TalklinerDimens.pipWidth,
              height: TalklinerDimens.pipHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  TalklinerDimens.pipBorderRadius,
                ),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  TalklinerDimens.pipBorderRadius,
                ),
                child: livekit.VideoTrackRenderer(
                  remoteTrack,
                  fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
