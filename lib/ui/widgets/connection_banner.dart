import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hid_service.dart';

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hid = ref.watch(hidProvider);
    final color = hid.status == ConnectionStatus.connected
        ? Colors.green
        : hid.status == ConnectionStatus.pairing
            ? Colors.orange
            : Colors.blueGrey;
    final text = switch (hid.status) {
      ConnectionStatus.connected => 'Connected: ${hid.connectedDeviceName.isEmpty ? "PC" : hid.connectedDeviceName}',
      ConnectionStatus.pairing => 'Pairing...',
      ConnectionStatus.error => 'Error: ${hid.errorMessage}',
      _ => 'Not Connected',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hid.status != ConnectionStatus.connected)
            ElevatedButton(
              onPressed: () => ref.read(hidProvider.notifier).connect(),
              child: const Text('Connect'),
            )
          else
            const Icon(Icons.bluetooth_connected, color: Colors.white),
        ],
      ),
    );
  }
}
