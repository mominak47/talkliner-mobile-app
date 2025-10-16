import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/app_settings_controller.dart';
import 'package:talkliner/app/views/profile/parts/settings_section_container.dart';
import 'package:talkliner/app/views/utils/radio_item.dart';

enum UserStatus {
  online,
  busy,
  solo,
  offline,
}

class UserSettingsMain extends StatelessWidget {
  const UserSettingsMain({super.key});

  @override
  Widget build(BuildContext context) {
  final AppSettingsController appSettingsController = Get.find<AppSettingsController>();

    return Obx(() => SettingsSectionContainer(
      title: 'Settings',
      children: [
        RadioItem(
          icon: LucideIcons.mic,
          label: 'Floating PTT',
          value: appSettingsController.showFloatingPushToTalkButton.value,
          onChanged: (value) => appSettingsController.setShowFloatingPushToTalkButton(value),
        ),
        RadioItem(
          icon: LucideIcons.vibrate,
          label: 'Vibrate on incoming PTT',
          value: appSettingsController.vibrateOnIncomingPTT.value,
          onChanged: (value) => appSettingsController.setVibrateOnIncomingPTT(value),
        ),
        RadioItem(
          icon: LucideIcons.bluetooth,
          label: 'When Bluetooth Disconnects',
          description: 'Divert to device speaker',
          value: appSettingsController.whenBluetoothDisconnects.value,
          onChanged: (value) => appSettingsController.setWhenBluetoothDisconnects(value),
        ),
        RadioItem(
          icon: LucideIcons.mic,
          label: 'PTT during cellular',
          description: 'Receive PTT while on cellular',
          value: appSettingsController.pttDuringCellular.value,
          onChanged: (value) => appSettingsController.setPttDuringCellular(value),
        ),
        RadioItem(
          icon: LucideIcons.phone,
          label: 'Reject Phone Calls',
          description: 'While in active PTT calls',
          value: appSettingsController.rejectPhoneCalls.value,
          onChanged: (value) => appSettingsController.setRejectPhoneCalls(value),
        ),
        RadioItem(
          icon: LucideIcons.bell,
          label: 'Incoming PTT Alert',
          value: appSettingsController.incomingPTTAlert.value,
          onChanged: (value) => appSettingsController.setIncomingPTTAlert(value),
        ),
        RadioItem(
          icon: LucideIcons.bell,
          label: 'Outgoing PTT Alert',
          value: appSettingsController.outgoingPTTAlert.value,
          onChanged: (value) => appSettingsController.setOutgoingPTTAlert(value),
        ),
        RadioItem(
          icon: LucideIcons.headphones,
          label: 'PTT earphones control',
          value: appSettingsController.pttEarphonesControl.value,
          onChanged: (value) => appSettingsController.setPttEarphonesControl(value),
        ),
      ],
    ));
  }
}