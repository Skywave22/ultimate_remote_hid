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

  HidState copyWith({
    ConnectionStatus? status,
    String? errorMessage,
    String? connectedDeviceName,
  }) {
    return HidState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
    );
  }
}

final hidProvider = StateNotifierProvider<HidNotifier, HidState>((ref) => HidNotifier());

class HidNotifier extends StateNotifier<HidState> {
  static const MethodChannel _channel = MethodChannel('com.ultimate_hid.bluetooth/hid');

  HidNotifier() : super(HidState()) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onStatusChanged') {
        state = state.copyWith(
          status: call.arguments == 'connected' ? ConnectionStatus.connected : ConnectionStatus.disconnected,
        );
      }
      if (call.method == 'onDeviceConnected') {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          connectedDeviceName: call.arguments ?? '',
        );
      }
      if (call.method == 'onError') {
        state = state.copyWith(
          status: ConnectionStatus.error,
          errorMessage: call.arguments ?? '',
        );
      }
    });
  }

  Future<void> connect() async {
    try {
      state = state.copyWith(status: ConnectionStatus.pairing);
      await _channel.invokeMethod('startHidService');
    } catch (e) {
      state = state.copyWith(status: ConnectionStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> sendKey(String key) async {
    if (state.status == ConnectionStatus.connected) {
      try {
        await _channel.invokeMethod('sendHidKey', {'key': key});
      } catch (_) {}
    }
  }

  Future<void> sendMouseMove(double dx, double dy) async {
    if (state.status == ConnectionStatus.connected) {
      try {
        await _channel.invokeMethod('sendMouseMove', {'dx': dx, 'dy': dy});
      } catch (_) {}
    }
  }
}
