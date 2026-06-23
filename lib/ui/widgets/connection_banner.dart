import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hid_service.dart';

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hid = ref.watch(hidProvider);
    return Container(padding: const EdgeInsets.all(10), color: hid.status == ConnectionStatus.connected ? Colors.green : Colors.blueGrey, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(hid.status == ConnectionStatus.connected ? "Connected: ${hid.connectedDeviceName}" : "Not Connected", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), if (hid.status != ConnectionStatus.connected) ElevatedButton(onPressed: () => ref.read(hidProvider.notifier).connect(), child: const Text("Connect"))]));
  }
}
