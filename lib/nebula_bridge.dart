import 'dart:convert';
import 'package:flutter/services.dart';

class NebulaBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.go_flutter_demo/nebula_bridge',
  );

  /// Starts the Nebula VPN with the given configuration
  Future<bool> startNebula(String config, String key) async {
    try {
      final result = await _channel.invokeMethod('startNebula', {
        'config': config,
        'key': key,
      });
      return result ?? false;
    } catch (e) {
      print('Failed to start Nebula: $e');
      return false;
    }
  }

  /// Stops the Nebula VPN
  Future<bool> stopNebula() async {
    try {
      final result = await _channel.invokeMethod('stopNebula');
      return result ?? false;
    } catch (e) {
      print('Failed to stop Nebula: $e');
      return false;
    }
  }

  /// Tests if the provided configuration is valid
  Future<bool> testConfig(String config, String key) async {
    try {
      final result = await _channel.invokeMethod('testConfig', {
        'config': config,
        'key': key,
      });
      return result ?? false;
    } catch (e) {
      print('Invalid configuration: $e');
      return false;
    }
  }

  /// Gets a list of all connected hosts in the Nebula network
  Future<Map<String, dynamic>> getHostmap() async {
    try {
      final String result = await _channel.invokeMethod('getHostmap');
      return json.decode(result) ?? {};
    } catch (e) {
      print('Failed to get hostmap: $e');
      return {};
    }
  }

  /// Forces a rebind of the UDP listener (useful when network changes)
  Future<bool> rebindNebula(String reason) async {
    try {
      final result = await _channel.invokeMethod('rebindNebula', {
        'reason': reason,
      });
      return result ?? false;
    } catch (e) {
      print('Failed to rebind Nebula: $e');
      return false;
    }
  }

  /// Pings a host in the Nebula network
  Future<bool> pingHost(String host) async {
    try {
      final result = await _channel.invokeMethod('pingHost', {'host': host});
      return result ?? false;
    } catch (e) {
      print('Failed to ping host: $e');
      return false;
    }
  }
}
