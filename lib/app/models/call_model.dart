import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';
enum CallType{
  individual,
  group;

  String get displayName {
    switch (this) {
      case CallType.individual:
        return 'Individual';
      case CallType.group:
        return 'Group';
    }
  }
}

enum CallDirection {
  incoming,
  outgoing;

  String get displayName {
    switch (this) {
      case CallDirection.incoming:
        return 'Incoming';
      case CallDirection.outgoing:
        return 'Outgoing';
    }
  }
}

enum CallStatus {
  calling,
  pending,
  accepted,
  rejected,
  busy,
  noAnswer,
  hold,
  ended;

  String get displayName {
    switch (this) {
      case CallStatus.calling:
        return 'Calling';
      case CallStatus.pending:
        return 'Pending';
      case CallStatus.accepted:
        return 'Accepted';
      case CallStatus.rejected:
        return 'Rejected';
      case CallStatus.busy:
        return 'Busy';
      case CallStatus.noAnswer:
        return 'No Answer';
      case CallStatus.ended:
        return 'Ended';
      case CallStatus.hold:
        return 'Hold';
    }
  }
}

class CallModel {
  final String id;
  String roomID;
  String roomToken;
  CallStatus status;
  final String createdAt;
  String updatedAt;
  CallType type;
  CallDirection direction;
  List<UserModel> participants;
  Function sendEvent;


  CallModel({
    required this.id,
    required this.direction,
    required this.type,
    required this.roomID,
    required this.roomToken,
    this.status = CallStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    required this.sendEvent,
  });


  void watchEvents(){
  }
  
  void updateStatus(String status){
    status = status;
    updatedAt = DateTime.now().toIso8601String();
  }

  void endCall(Function cb){
    debugPrint('CallModel: Ending call: $id');
    sendEvent('end', participants.first.id, null, (response) {
      cb(response);
    });
  }

  void rejectCall(Function cb){
    sendEvent('reject', participants.first.id, null, (response) {
      cb(response);
    });
  }

  void updateRoomID(String roomID){
    this.roomID = roomID;
  }

  void updateRoomToken(String roomToken){
    this.roomToken = roomToken;
  }

  void showPopup(){
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

    UserModel user = participants.first;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        backgroundColor:
            isDarkMode
                ? TalklinerThemeColors.gray800
                : TalklinerThemeColors.gray020,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(user: user, size: 100, indicator: false),
            SizedBox(height: 20),
            Text(
              user.displayName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Incoming call..',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 32,
            backgroundColor: TalklinerThemeColors.green500,
            child: IconButton(
              iconSize: 24,
              onPressed: () {
              },
              icon: Icon(LucideIcons.check, color: Colors.white),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: TalklinerThemeColors.red500,
            child: IconButton(
              iconSize: 24,
              onPressed: () {
                rejectCall((response) {
                  debugPrint('CallModel: Call rejected: $response');
                });
                Get.back();
                // Get parent of the class
                Get.find<CallController>().removeCall(this);
              },
              icon: Icon(LucideIcons.x, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  factory CallModel.make(
    {
      required String callId,
      required CallDirection direction,
      required CallType type,
      String? roomID,
      String? roomToken,
      required CallStatus status,
      String? createdAt,
      String? updatedAt,
      required List<UserModel> participants,
      required Function sendEvent,
    }
  ){
    CallModel call = CallModel(
      id: callId,
      direction: direction,
      type: type,
      roomID: roomID ?? '',
      roomToken: roomToken ?? '',
      status: status,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      participants: participants,
      sendEvent: sendEvent,
    );

    call.watchEvents();

    return call;
  }
}