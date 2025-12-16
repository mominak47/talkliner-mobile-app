import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/emergency_active_screen.dart';
import 'package:torch_light/torch_light.dart';

class EmergencyController extends GetxController {
  Timer? _timer;
  final RxInt countdownSeconds = 30.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void triggerEmergency() {
    countdownSeconds.value = 30;
    _startCountdown();
    HapticFeedback.heavyImpact(); // Immediate feedback on trigger
    _audioPlayer.play(AssetSource('audio/emergency-tick-sound.mp3'));

    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor:
              isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Emergency call will start in',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Obx(
                        () => CircularProgressIndicator(
                          value: countdownSeconds.value / 30.0,
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TalklinerThemeColors.red500,
                          ),
                          backgroundColor:
                              isDarkMode
                                  ? TalklinerThemeColors.gray700
                                  : TalklinerThemeColors.gray030,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${countdownSeconds.value}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : TalklinerThemeColors.gray900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _stopTimer();
                      Get.back(); // Close dialog
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        TalklinerThemeColors.primary500,
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0), // No elevation
                      overlayColor: WidgetStateProperty.all(
                        Colors.black12,
                      ), // Custom splash if needed
                    ),
                    child: const Text(
                      "I'm okay",
                      style: TextStyle(
                        color: Colors.black, // Assuming black text on amber
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _performEmergencyCall();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        TalklinerThemeColors.gray020,
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: const Text(
                      "Call Now",
                      style: TextStyle(
                        color: TalklinerThemeColors.gray900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
        HapticFeedback.heavyImpact();
        _audioPlayer.play(AssetSource('audio/emergency-tick-sound.mp3'));
        _flashTorch();
      } else {
        _performEmergencyCall();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _performEmergencyCall() {
    _stopTimer();
    // Placeholder for actual call logic
    // Close dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    // Navigate to active screen
    Get.to(() => const EmergencyActiveScreen());
  }

  void cancelEmergencyCall() {
    debugPrint("Emergency Call Cancelled by User");
    // Any logic to actually stop a call if it was started
    Get.back(); // Go back to main screen
  }

  Future<void> _flashTorch() async {
    try {
      if (await TorchLight.isTorchAvailable()) {
        await TorchLight.enableTorch();
        // Wait briefly then turn off
        await Future.delayed(const Duration(milliseconds: 100));
        await TorchLight.disableTorch();
      }
    } catch (e) {
      debugPrint("Torch error: $e");
    }
  }

  @override
  void onClose() {
    _stopTimer();
    _audioPlayer.dispose();
    TorchLight.disableTorch();
    super.onClose();
  }
}
