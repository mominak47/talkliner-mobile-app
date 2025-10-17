import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';

class SignalBarsWidget extends StatelessWidget {
  const SignalBarsWidget({super.key});

  Icon _getSignalIcon(SocketConnectionQuality connectionQuality) {
    switch (connectionQuality) {
      case SocketConnectionQuality.excellent:
        return const Icon(LucideIcons.signalHigh, color: Colors.green);
      case SocketConnectionQuality.good:
        return const Icon(LucideIcons.signal, color: Colors.green);
      case SocketConnectionQuality.fair:
        return const Icon(LucideIcons.signalLow, color: Colors.orange);
      case SocketConnectionQuality.poor:
        return const Icon(LucideIcons.signal, color: Colors.red);
      case SocketConnectionQuality.veryPoor:
        return const Icon(LucideIcons.signalZero, color: Colors.red);
      case SocketConnectionQuality.disconnected:
        return const Icon(LucideIcons.signalZero, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketController = Get.find<SocketController>();
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _getSignalIcon(socketController.connectionQuality.value),
      )
    );
  }
}
