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
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB( 18, 0, 8, 0),
              child: _getSignalIcon(socketController.connectionQuality.value),
            ),
            Positioned(
              top: 0,
              left: 4,
              right: 0,
              bottom: 0,
              child: Text("${socketController.latency.value.toInt().toString()}ms",
              style: TextStyle(fontSize: 8, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      )
    );
  }
}
