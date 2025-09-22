import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class CheckInternet {
  static final Connectivity _connectivity = Connectivity();

  static List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  static Future<List<ConnectivityResult>> initConnectivity() async {
    List<ConnectivityResult> result = [];
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {}

    return updateConnectionStatus(result);
  }

  static Future<List<ConnectivityResult>> updateConnectionStatus(List<ConnectivityResult> results) async {
    // Create a new list based on the current status
    List<ConnectivityResult> newStatus = List.from(_connectionStatus);

    // Clear the current status and add the new results
    newStatus.clear();
    for (var result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.none:
          newStatus.add(result);
          break;
        default:
          newStatus.add(ConnectivityResult.none);
          break;
      }
    }

    // Update the static list with the new status
    _connectionStatus = newStatus;

    return _connectionStatus;
  }
}
