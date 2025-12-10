import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';

class LiveKitSignalWidget extends StatelessWidget {
  const LiveKitSignalWidget({super.key});

  Icon _getSignalIcon(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return const Icon(
          LucideIcons.signalHigh,
          color: Colors.green,
          size: 16,
        );
      case ConnectionQuality.good:
        return const Icon(LucideIcons.signal, color: Colors.green, size: 16);
      case ConnectionQuality.poor:
        return const Icon(
          LucideIcons.signalLow,
          color: Colors.orange,
          size: 16,
        );
      case ConnectionQuality.unknown:
      default:
        return const Icon(LucideIcons.signalZero, color: Colors.red, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final quality = callController.connectionQuality.value;
      final latency = callController.currentLatency.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black26 : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getSignalIcon(quality),
            const SizedBox(width: 4),
            Text(
              "${latency.toInt()} ms",
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}
