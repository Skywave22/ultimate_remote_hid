import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hid_service.dart';

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hid = ref.watch(hidProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: _getStatusColor(hid.status),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_getStatusIcon(hid.status), color: Colors.white),
              const SizedBox(width: 10),
              Text(
                hid.status == ConnectionStatus.connected 
                  ? "Connected to ${hid.connectedDeviceName}" 
                  : _getStatusText(hid.status),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (hid.status == ConnectionStatus.disconnected)
            ElevatedButton(
              onPressed: () => ref.read(hidProvider.notifier).connect(),
              child: const Text("Connect Device"),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected: return Colors.green;
      case ConnectionStatus.pairing: return Colors.orange;
      case ConnectionStatus.error: return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected: return Icons.bluetooth_connected;
      case ConnectionStatus.pairing: return Icons.sync;
      case ConnectionStatus.error: return Icons.error;
      default: return Icons.bluetooth_disabled;
    }
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.pairing: return "Pairing with device...";
      case ConnectionStatus.error: return "Error: ${hidProvider.state.errorMessage}";
      default: return "No Device Connected";
    }
  }
}
