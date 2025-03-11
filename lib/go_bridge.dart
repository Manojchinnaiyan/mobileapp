import 'package:flutter/services.dart';

class GoBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.go_flutter_demo/go_bridge',
  );

  Future<String> callSimpleFunction(String input) async {
    try {
      final result = await _channel.invokeMethod('simpleFunction', {
        'input': input,
      });
      return result.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<int> sumNumbers(int a, int b) async {
    try {
      final result = await _channel.invokeMethod('sumNumbers', {
        'a': a,
        'b': b,
      });
      return result as int;
    } catch (e) {
      return -1;
    }
  }
}
