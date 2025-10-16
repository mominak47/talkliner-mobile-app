# Socket Connection Provider Usage Guide

This guide covers how to use the Socket Connection Provider in your Talkliner app for managing socket connections, network latency, and connection quality with Riverpod state management.

## Table of Contents
1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Available Providers](#available-providers)
4. [Connection Management](#connection-management)
5. [Network Quality Monitoring](#network-quality-monitoring)
6. [UI Integration Examples](#ui-integration-examples)
7. [Error Handling](#error-handling)
8. [Best Practices](#best-practices)

## Overview

The Socket Connection Provider manages:
- Real-time socket connection state
- Network latency monitoring with signal bars (0-4)
- Connection quality assessment (excellent to disconnected)
- Automatic reconnection with exponential backoff
- Connection uptime and error tracking
- Integration with existing SocketService

## Basic Usage

### 1. Import the Provider

```dart
import 'package:talkliner/providers/socket_connection_provider.dart';
```

### 2. Basic Connection Status Display

```dart
class ConnectionStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isSocketConnectedProvider);
    final latencyText = ref.watch(latencyTextProvider);
    final signalBars = ref.watch(signalBarsProvider);
    
    return Row(
      children: [
        Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: isConnected ? Colors.green : Colors.red,
        ),
        SizedBox(width: 4),
        Text(latencyText),
        SizedBox(width: 4),
        SvgPicture.asset(
          'assets/signals/$signalBars.svg',
          width: 20,
          height: 20,
        ),
      ],
    );
  }
}
```

## Available Providers

### Main Provider
- `socketConnectionProvider` - Complete connection state

### Convenience Providers
- `isSocketConnectedProvider` - Boolean connection status
- `networkLatencyProvider` - Latency in milliseconds (-1 = disconnected)
- `signalBarsProvider` - Signal strength (0-4 bars)
- `connectionQualityProvider` - Quality enum (excellent to disconnected)
- `latencyTextProvider` - Formatted latency text ("50ms" or "Disconnected")
- `connectionStatusProvider` - Human-readable status
- `hasConnectionErrorProvider` - Boolean error state
- `connectionUptimeProvider` - Duration since connected
- `signalIconPathProvider` - Path to signal icon asset
- `qualityColorProvider` - Hex color for quality indicator

### Connection Quality Levels
```dart
enum SocketConnectionQuality {
  excellent,    // < 50ms - Green
  good,        // 50-100ms - Light green  
  fair,        // 100-200ms - Yellow
  poor,        // 200-500ms - Orange
  veryPoor,    // > 500ms - Red
  disconnected, // -1 - Gray
}
```

## Connection Management

### Manual Connection Control

```dart
class ConnectionControlWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionProvider);
    final notifier = ref.read(socketConnectionProvider.notifier);
    
    return Column(
      children: [
        Text('Status: ${connectionState.connectionStatus}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: connectionState.isConnecting 
                  ? null 
                  : () => notifier.connect(),
              child: Text('Connect'),
            ),
            ElevatedButton(
              onPressed: !connectionState.isConnected 
                  ? null 
                  : () => notifier.disconnect(),
              child: Text('Disconnect'),
            ),
            ElevatedButton(
              onPressed: connectionState.isReconnecting 
                  ? null 
                  : () => notifier.reconnect(),
              child: Text('Reconnect'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Force Connection (for debugging)

```dart
// Force connection attempt
await ref.read(socketConnectionProvider.notifier).forceConnect();

// Clear error state
ref.read(socketConnectionProvider.notifier).clearError();
```

## Network Quality Monitoring

### Signal Bars Display

```dart
class SignalBarsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalIconPath = ref.watch(signalIconPathProvider);
    final quality = ref.watch(connectionQualityProvider);
    final qualityColor = ref.watch(qualityColorProvider);
    
    return Column(
      children: [
        SvgPicture.asset(
          signalIconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            Color(int.parse(qualityColor.substring(1), radix: 16) + 0xFF000000),
            BlendMode.srcIn,
          ),
        ),
        Text(
          quality.name.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Color(int.parse(qualityColor.substring(1), radix: 16) + 0xFF000000),
          ),
        ),
      ],
    );
  }
}
```

### Latency Monitor

```dart
class LatencyMonitorWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionProvider);
    final latency = ref.watch(networkLatencyProvider);
    final uptime = ref.watch(connectionUptimeProvider);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network Status', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Latency:'),
                Text(
                  connectionState.latencyText,
                  style: TextStyle(
                    color: _getLatencyColor(latency),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quality:'),
                Text(
                  connectionState.quality.name.toUpperCase(),
                  style: TextStyle(
                    color: Color(int.parse(
                      ref.read(qualityColorProvider).substring(1), 
                      radix: 16
                    ) + 0xFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (uptime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Uptime:'),
                  Text(_formatDuration(uptime)),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reconnects:'),
                Text('${connectionState.reconnectAttempts}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getLatencyColor(int latency) {
    if (latency == -1) return Colors.grey;
    if (latency < 50) return Colors.green;
    if (latency < 100) return Colors.lightGreen;
    if (latency < 200) return Colors.yellow;
    if (latency < 500) return Colors.orange;
    return Colors.red;
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
```

## UI Integration Examples

### Header Widget Integration

```dart
class MainHeaderWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isSocketConnectedProvider);
    final signalIconPath = ref.watch(signalIconPathProvider);
    final latencyText = ref.watch(latencyTextProvider);
    
    return AppBar(
      title: Text('Talkliner'),
      actions: [
        // Connection status indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                signalIconPath,
                width: 16,
                height: 16,
              ),
              SizedBox(width: 4),
              Text(
                latencyText,
                style: TextStyle(
                  fontSize: 12,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
```

### Connection Status Card

```dart
class ConnectionStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionProvider);
    final hasError = ref.watch(hasConnectionErrorProvider);
    
    return Card(
      color: hasError ? Colors.red[50] : null,
      child: ListTile(
        leading: Icon(
          connectionState.isConnected 
              ? Icons.wifi 
              : connectionState.isConnecting 
                  ? Icons.wifi_find
                  : Icons.wifi_off,
          color: connectionState.isConnected 
              ? Colors.green 
              : connectionState.isConnecting 
                  ? Colors.orange
                  : Colors.red,
        ),
        title: Text(connectionState.connectionStatus),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latency: ${connectionState.latencyText}'),
            if (connectionState.lastError != null)
              Text(
                'Error: ${connectionState.lastError}',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: connectionState.isConnecting || connectionState.isReconnecting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : SvgPicture.asset(
                ref.watch(signalIconPathProvider),
                width: 24,
                height: 24,
              ),
      ),
    );
  }
}
```

### Settings Screen Integration

```dart
class NetworkSettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionProvider);
    final notifier = ref.read(socketConnectionProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network Connection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        
        // Connection status
        ConnectionStatusCard(),
        
        SizedBox(height: 16),
        
        // Connection controls
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: connectionState.isConnecting 
                  ? null 
                  : () => notifier.connect(),
              icon: Icon(Icons.wifi),
              label: Text('Connect'),
            ),
            ElevatedButton.icon(
              onPressed: !connectionState.isConnected 
                  ? null 
                  : () => notifier.disconnect(),
              icon: Icon(Icons.wifi_off),
              label: Text('Disconnect'),
            ),
            OutlinedButton.icon(
              onPressed: () => notifier.forceConnect(),
              icon: Icon(Icons.refresh),
              label: Text('Force Reconnect'),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Network diagnostics
        LatencyMonitorWidget(),
      ],
    );
  }
}
```

## Error Handling

### Error Display and Recovery

```dart
class ConnectionErrorHandler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasError = ref.watch(hasConnectionErrorProvider);
    final connectionState = ref.watch(socketConnectionProvider);
    
    if (!hasError) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Connection Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(connectionState.lastError ?? 'Unknown error'),
          SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(socketConnectionProvider.notifier).clearError();
                  ref.read(socketConnectionProvider.notifier).reconnect();
                },
                child: Text('Retry'),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: () => ref.read(socketConnectionProvider.notifier).clearError(),
                child: Text('Dismiss'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Listening for Connection Changes

```dart
class ConnectionListener extends ConsumerStatefulWidget {
  final Widget child;
  
  const ConnectionListener({required this.child});
  
  @override
  ConsumerState<ConnectionListener> createState() => _ConnectionListenerState();
}

class _ConnectionListenerState extends ConsumerState<ConnectionListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen<SocketConnectionState>(
      socketConnectionProvider,
      (previous, next) {
        // Handle connection state changes
        if (previous?.isConnected == true && next.isConnected == false) {
          // Connection lost
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection lost'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Reconnect',
                onPressed: () => ref.read(socketConnectionProvider.notifier).reconnect(),
              ),
            ),
          );
        } else if (previous?.isConnected == false && next.isConnected == true) {
          // Connection restored
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connected'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Handle errors
        if (next.hasError && previous?.lastError != next.lastError) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Connection Error'),
              content: Text(next.lastError!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(socketConnectionProvider.notifier).reconnect();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
      },
    );
    
    return widget.child;
  }
}
```

## Best Practices

### 1. Provider Usage
- Use specific convenience providers instead of watching the full state when possible
- Watch `isSocketConnectedProvider` for simple connection checks
- Use `signalIconPathProvider` for consistent signal icon display

### 2. UI Updates
- Show connection status in headers or status bars
- Provide manual reconnect options in settings
- Display latency for real-time applications

### 3. Error Handling
- Always handle connection errors gracefully
- Provide retry mechanisms for users
- Show appropriate loading states during connection attempts

### 4. Performance
- The provider automatically manages subscriptions and timers
- Use `ref.listen` for side effects, not continuous UI updates
- Avoid calling connection methods too frequently

### 5. Integration
- The provider works seamlessly with existing SocketService
- No need to modify existing socket event handling
- Provides additional state management on top of current implementation

## Complete Example: Connection Status in App Bar

```dart
class AppBarWithConnection extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isSocketConnectedProvider);
    final latencyText = ref.watch(latencyTextProvider);
    final signalIconPath = ref.watch(signalIconPathProvider);
    final quality = ref.watch(connectionQualityProvider);
    
    return AppBar(
      title: Text('Talkliner'),
      backgroundColor: isConnected ? null : Colors.red[700],
      actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                signalIconPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 6),
              Text(
                latencyText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
```

This socket connection provider provides a robust, reactive way to manage socket connections with comprehensive state tracking and automatic recovery mechanisms!
