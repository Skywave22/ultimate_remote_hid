import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout_engine.dart';

class PowerModePanel extends ConsumerWidget {
  final AppComponent selectedComp;
  const PowerModePanel({super.key, required this.selectedComp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController(text: selectedComp.label);
    final actionCtrl = TextEditingController(text: selectedComp.actionValue);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit ${selectedComp.type.name}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: labelCtrl,
            decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
            onChanged: (val) => ref
                .read(layoutProvider.notifier)
                .updateComponentProperty(selectedComp.id, {'label': val}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: actionCtrl,
            decoration: const InputDecoration(labelText: 'Action / Key', border: OutlineInputBorder()),
            onChanged: (val) => ref
                .read(layoutProvider.notifier)
                .updateComponentProperty(selectedComp.id, {'action': val}),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                ref.read(layoutProvider.notifier).removeComponent(selectedComp.id);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Component'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
