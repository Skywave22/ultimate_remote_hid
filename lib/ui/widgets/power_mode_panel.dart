import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout_engine.dart';

class PowerModePanel extends ConsumerWidget {
  final AppComponent selectedComp;

  const PowerModePanel({super.key, required this.selectedComp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Power Mode: Edit Component", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(labelText: "Button Label", border: OutlineInputBorder()),
            onChanged: (val) => ref.read(layoutProvider.notifier).updateComponentProperty(selectedComp.id, {'label': val}),
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: const InputDecoration(labelText: "HID Action", border: OutlineInputBorder()),
            onChanged: (val) => ref.read(layoutProvider.notifier).updateComponentProperty(selectedComp.id, {'action': val}),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text("Color: "),
              const SizedBox(width: 10),
              ...[Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple].map((color) {
                return GestureDetector(
                  onTap: () => ref.read(layoutProvider.notifier).updateComponentProperty(selectedComp.id, {'color': color}),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => ref.read(layoutProvider.notifier).removeComponent(selectedComp.id),
              child: const Text("Delete Component"),
            ),
          ),
        ],
      ),
    );
  }
}
