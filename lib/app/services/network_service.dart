
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  // Private constructor
  NetworkService._internal();

  // Singleton instance
  static final NetworkService _instance = NetworkService._internal();

  // Factory constructor
  factory NetworkService() => _instance;



  String getNetworkType() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_connectionStatus.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else {
      return 'No Connection';
    }
  }

  Map<String, dynamic> getNetworkInfo() {
    return {
      'networkType': getNetworkType(),
      'connectionStatus': _connectionStatus.map((e) => e.name).toList(),
    };
  }

}