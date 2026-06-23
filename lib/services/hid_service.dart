import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectionStatus { disconnected, pairing, connected, error }

class HidState {
  final ConnectionStatus status;
  final String errorMessage;
  final String connectedDeviceName;

  HidState({
    this.status = ConnectionStatus.disconnected,
    this.errorMessage = '',
    this.connectedDeviceName = '',
  });

  HidState copyWith({ConnectionStatus? status, String? errorMessage, String? connectedDeviceName}) {
    return HidState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
    );
  }
}

final hidProvider = StateNotifierProvider<HidNotifier, HidState>((ref) {
  return HidNotifier();
});

class HidNotifier extends StateNotifier<HidState> {
  static const MethodChannel _channel = MethodChannel('com.ultimate_hid.bluetooth/hid');

  HidNotifier() : super(HidState()) {
    _initListener();
  }

  void _initListener() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStatusChanged':
          state = state.copyWith(status: _mapStatus(call.arguments));
          break;
        case 'onError':
          state = state.copyWith(status: ConnectionStatus.error, errorMessage: call.arguments);
          break;
        case 'onDeviceConnected':
          state = state.copyWith(status: ConnectionStatus.connected, connectedDeviceName: call.arguments);
          break;
      }
    });
  }

  ConnectionStatus _mapStatus(String status) {
    switch (status) {
      case 'pairing': return ConnectionStatus.pairing;
      case 'connected': return ConnectionStatus.connected;
      default: return ConnectionStatus.disconnected;
    }
  }

  Future<void> connect() async {
    try {
      await _channel.invokeMethod('startHidService');
    } catch (e) {
      state = state.copyWith(status: ConnectionStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> sendKey(String key) async {
    if (state.status != ConnectionStatus.connected) {
      state = state.copyWith(status: ConnectionStatus.error, errorMessage: "Please connect a device first!");
      return;
    }
    try {
      await _channel.invokeMethod('sendHidKey', {'key': key});
    } catch (e) {
      print("HID Send Error: ");
    }
  }

  Future<void> sendMouseMove(double dx, double dy) async {
    if (state.status != ConnectionStatus.connected) return;
    try {
      await _channel.invokeMethod('sendMouseMove', {'dx': dx, 'dy': dy});
    } catch (e) {
      print("Mouse Move Error: ");
    }
  }
}
