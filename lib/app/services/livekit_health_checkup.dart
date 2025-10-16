import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

enum ConnectionState {
  connected,
  reconnecting,
  disconnected,
}

class ConnectionHealthMonitor {
  Room? _room;
  Timer? _healthCheckTimer;
  
  void startHealthCheck(Room room) {
    _room = room;
    _healthCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkConnectionHealth();
    });
  }
  
  void _checkConnectionHealth() {
    if (_room == null) return;
    
    final isHealthy = _room!.connectionState == ConnectionState.connected &&
                      _room!.localParticipant != null &&
                      _room!.serverVersion != null;
    
    if (!isHealthy) {
      debugPrint('Connection health check failed');
      _attemptReconnection();
    } else {
      debugPrint('Connection healthy');
    }
  }
  
  Future<void> _attemptReconnection() async {
    if (_room?.connectionState == ConnectionState.reconnecting) {
      return; // Already reconnecting
    }
    
    try {
      await _room?.disconnect();
      // Re-connect logic here
    } catch (e) {
      debugPrint('Reconnection failed: $e');
    }
  }
  
  void stopHealthCheck() {
    _healthCheckTimer?.cancel();
  }
}