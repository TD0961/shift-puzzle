import 'dart:async';
import 'connectivity_checker.dart';

/// Contract for checking network and internet connectivity.
///
/// Shift Puzzle is strictly offline-first: all puzzle solving, levels,
/// Memory Echo, scoring, and progress saving work without an internet connection.
/// Network connectivity is only required for rewarded video advertisements (such as hints).
abstract class ConnectivityService {
  /// Checks whether usable network connectivity is currently available.
  Future<bool> hasInternetConnection();
}

/// Standard production implementation using platform-native network checks.
class NetworkConnectivityService implements ConnectivityService {
  const NetworkConnectivityService();

  @override
  Future<bool> hasInternetConnection() => checkNetworkConnectivity();
}

/// Controllable mock connectivity service for testing offline/online transitions.
class MockConnectivityService implements ConnectivityService {
  bool isOnline;
  int checkCount = 0;

  MockConnectivityService({this.isOnline = true});

  @override
  Future<bool> hasInternetConnection() async {
    checkCount++;
    return isOnline;
  }
}
