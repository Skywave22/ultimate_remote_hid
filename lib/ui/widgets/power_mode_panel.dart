import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout_engine.dart';

class PowerModePanel extends ConsumerWidget {
  final AppComponent selectedComp;
  const PowerModePanel({super.key, required this.selectedComp});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(decoration: const InputDecoration(labelText: "Label"), onChanged: (val) => ref.read(layoutProvider.notifier).updateComponentProperty(selectedComp.id, {'label': val})),
      TextField(decoration: const InputDecoration(labelText: "Action"), onChanged: (val) => ref.read(layoutProvider.notifier).updateComponentProperty(selectedComp.id, {'action': val})),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => ref.read(layoutProvider.notifier).removeComponent(selectedComp.id), child: const Text("Delete", style: TextStyle(color: Colors.white)))),
    ]));
  }
}
