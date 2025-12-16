import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/controllers/emergency_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmergencyActiveScreen extends StatefulWidget {
  const EmergencyActiveScreen({super.key});

  @override
  State<EmergencyActiveScreen> createState() => _EmergencyActiveScreenState();
}

class _EmergencyActiveScreenState extends State<EmergencyActiveScreen> {
  bool _isHolding = false;
  Timer? _holdTimer;
  final EmergencyController controller = Get.find<EmergencyController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isHolding = true;
        });
        HapticFeedback.mediumImpact();

        // Wait 1 second before cancelling
        _holdTimer = Timer(const Duration(seconds: 1), () {
          if (_isHolding) {
            HapticFeedback.heavyImpact();
            controller.cancelEmergencyCall();
          }
        });
      },
      onLongPressEnd: (_) {
        _holdTimer?.cancel();
        setState(() {
          _isHolding = false;
        });
      },
      child: Scaffold(
        backgroundColor: _isHolding ? Colors.red : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 100,
          leading: TextButton.icon(
            onPressed: () {
              // Also allow back button to cancel? Or strictly tap and hold?
              // User requirement was "tap and hold... brings user back".
              // Image has "Back". Let's handle it as cancel too for safety.
              controller.cancelEmergencyCall();
            },
            icon: Icon(
              LucideIcons.chevronLeft,
              color: _isHolding ? Colors.white : Colors.black,
            ),
            label: Text(
              "Back",
              style: TextStyle(
                color: _isHolding ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color:
                      _isHolding
                          ? Colors.white.withOpacity(0.2)
                          : TalklinerThemeColors.red050,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color:
                      _isHolding ? Colors.white : TalklinerThemeColors.red500,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Emergency call",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isHolding ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tap and hold to cancel the call",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _isHolding ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(
                height: 100,
              ), // Spacing to push content up slightly
            ],
          ),
        ),
      ),
    );
  }
}
