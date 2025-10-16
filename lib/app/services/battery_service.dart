import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

class BatteryService {
  final Battery _battery = Battery();

  double _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  // Private constructor
  BatteryService._internal();

  // Singleton instance
  static final BatteryService _instance = BatteryService._internal();

  // Factory constructor
  factory BatteryService() => _instance;

  void init() {
    getBatteryInfo();
    _listenToBatteryChanges();
  }

  // Get current battery level
  Future<void> getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      _batteryLevel = batteryLevel.toDouble();
      _batteryState = batteryState;
    } catch (e) {
      debugPrint('Error getting battery info: $e');
    }
  }

  // Listen to battery level changes
  void _listenToBatteryChanges() {
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryState = state;
    });
  }

  double get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  Map<String, dynamic> getBatteryInfoMap() {
    return {
      'batteryLevel': _batteryLevel,
      'batteryState': _batteryState.name,
    };
  }
}
